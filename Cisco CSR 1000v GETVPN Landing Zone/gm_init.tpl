Section: IOS configuration
crypto keyring GWAN
!
pre-shared-key address <AUS-KEY-IP> key <gvg-preshared-key>
pre-shared-key address <AUE-KEY-IP> key <gvg-preshared-key>
!
crypto isakmp policy 20
encr aes 256
hash sha256
authentication pre-share
group 19
lifetime 1200
!
crypto gdoi group GWAN-GDOI-GROUP
identity number 200
server address ipv4 <AUS-KEY-IP>
server address ipv4 <AUE-KEY-IP>
client registration interface GigabitEthernet1
!
crypto map GWAN-GETVPN-MAP 10 gdoi
set group GWAN-GDOI-GROUP
!
interface GigabitEthernet1
crypto map GWAN-GETVPN-MAP
ip tcp adjust-mss 1300
!
password encryption aes