#  Дипломная работа по профессии «Системный администратор» Невзорова Владислава Викторовича SYS-23

Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Все VM и ссылки на конфигурации Terraform и Ansible](#все-vm)

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal  

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/VM_specs.png)

**Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю сделайте ваши ВМ постоянно работающими.**

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
## [Ссылка на сайт](http://158.160.144.8:80)

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/Web_site.png)

Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/web_servers_network_map.png)

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/target.png)

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/backend.png)

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/router.png)

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/alb.png)

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/curl.png)

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

## [Zabbix](http://158.160.143.96:8080)

login: netology
pass: diplomsys23

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/zabbix.png)

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

## [Kibana](http://158.160.140.26:5601)

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/Kibana.png)

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.
## Полная карта сети

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/network_map.png)

subnet-1 сеть для web-server-1 (толко private IP)
subnet-2 сеть для web-server-2 (толко private IP)
subnet-3 сеть для elasticserch (толко private IP)
subnet-4 сеть для Zabbix, Kibana, Bastion host (помимо private IP имеют global IP)

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/sg.png)

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)


### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/snapshot.png)

## Все VM

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/vm.png)

## [Конфигурация Terraform](https://github.com/VN351/diplom-sys23-nevzorovvv/tree/main/terraform)

## [Конфигурация Ansible](https://github.com/VN351/diplom-sys23-nevzorovvv/tree/main/ansible)
Настройка VM происходила с локального ПК через bastion host с использованием команды 

ansible-playbook -i ./inventory.ini playbook.yml -u vlad --ssh-common-args='-o ProxyJump=vlad@158.160.135.116'

![alt text](https://github.com/VN351/diplom-sys23-nevzorovvv/raw/main/img/ansible.png)
 

