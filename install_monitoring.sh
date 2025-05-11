#!/bin/bash

set -e  # Прерывание при ошибках

# --- 1. Установка Prometheus ---
echo "➜ Установка Prometheus..."

# Создаем пользователя prometheus
if ! id prometheus &>/dev/null; then
    sudo useradd --no-create-home --shell /bin/false prometheus
    echo "✓ Пользователь 'prometheus' создан"
else
    echo "✓ Пользователь 'prometheus' уже существует"
fi

# Каталоги для Prometheus
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Скачиваем и распаковываем Prometheus
PROM_VERSION="2.47.0"
PROM_URL="https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"

echo "➜ Скачивание Prometheus v${PROM_VERSION}..."
wget -qO- "$PROM_URL" | tar xz --strip-components=1 -C .

# Копируем бинарники и настраиваем права
sudo cp prometheus promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}

# Копируем конфиги
sudo cp -r consoles console_libraries /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus/{consoles,console_libraries}

# Создаем конфиг prometheus.yml
sudo tee /etc/prometheus/prometheus.yml >/dev/null <<EOF
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

# Создаем systemd-юнит
sudo tee /etc/systemd/system/prometheus.service >/dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Запускаем Prometheus
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
echo "✓ Prometheus установлен и запущен (http://localhost:9090)"

# --- 2. Установка Grafana ---
echo "➜ Установка Grafana..."

GRAFANA_VERSION="10.2.0"
GRAFANA_DEB="grafana_${GRAFANA_VERSION}_amd64.deb"
GRAFANA_URL="https://dl.grafana.com/oss/release/${GRAFANA_DEB}"

echo "➜ Скачивание Grafana ${GRAFANA_VERSION}..."
wget -q "$GRAFANA_URL"
sudo dpkg -i "$GRAFANA_DEB"
sudo apt-get install -fy  # Исправляем зависимости

# Запускаем Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
echo "✓ Grafana установлена и запущена (http://localhost:3000)"

# --- Готово ---
echo ""
echo "✅ Установка завершена!"
echo "- Prometheus: http://$(hostname -I | awk '{print $1}'):9090"
echo "- Grafana:    http://$(hostname -I | awk '{print $1}'):3000"
echo "Логин/пароль Grafana: admin/admin (смените после входа)"