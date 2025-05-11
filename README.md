# 📊 Auto Install Prometheus + Grafana (Ubuntu)

Автоматическая установка **Prometheus** (с systemd-юнитом) и **Grafana** (через .deb пакет) на Ubuntu.

## 📌 Возможности
- Устанавливает Prometheus как службу (`systemd`).
- Настраивает базовый конфиг `prometheus.yml`.
- Устанавливает Grafana из `.deb`-пакета (без GPG-ключа).
- Выводит ссылки для доступа после установки.

## 🚀 Быстрый старт
```bash
# Скачать и запустить
wget https://raw.githubusercontent.com/ваш-репозиторий/main/install_monitoring.sh
chmod +x install_monitoring.sh
sudo ./install_monitoring.sh

## Смена версии
```bash
# Версию ПО можно изменить в переменных скрипта
PROM_VERSION="2.47.0"
GRAFANA_VERSION="10.2.0"