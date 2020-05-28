Section: IOS configuration
ip access-list extended GETVPN-POLICY-ACL
deny   esp any any
deny   tcp any any eq tacacs
deny   tcp any eq tacacs any
deny   tcp any any eq 22
deny   tcp any eq 22 any
deny   tcp any any eq bgp
deny   tcp any eq bgp any
deny   tcp any eq 443 any
deny   tcp any any eq 443
deny   udp any eq isakmp any eq isakmp
deny   udp any eq 848 any eq 848
deny   udp any any eq ntp
deny   udp any eq ntp any
deny   udp any any eq snmp
deny   udp any eq snmp any
deny   udp any any eq syslog
deny   udp any eq syslog any
permit ip any any
!
access-list 52 permit <AUC-GM1-IP>
access-list 52 permit <AUC-GM2-IP>
!
crypto isakmp policy 20
encr aes 256
hash sha256
authentication pre-share
group 19
lifetime 1200
!
crypto isakmp keepalive 15 periodic
!
crypto isakmp key <preshared-key> address <AUC-GM1-IP>
crypto isakmp key <preshared-key> address <AUC-GM2-IP>
crypto isakmp key <preshared-key> address <AUS-GM1-IP>
crypto isakmp key <preshared-key> address <AUS-GM2-IP>
crypto isakmp key <preshared-key> address <AUE-GM1-IP>
crypto isakmp key <preshared-key> address <AUE-GM2-IP>
crypto isakmp key <preshared-key> address <AUE-KEY-IP>
!
crypto ipsec transform-set AES256-SHA256 esp-aes 256 esp-sha256-hmac
!
crypto ipsec profile GETVPN-PROFILE
set security-association lifetime seconds 7200
set transform-set AES256-SHA256
!
! Generate and Export an RSA Key
crypto key generate rsa label GETVPN-REKEY-RSA modulus 2048 exportable
!
! export the key and import to other KS - Commands below
!
! crypto key export rsa GETVPN-REKEY-RSA pem terminal 3des Aussuper!
! crypto key import rsa GETVPN-REKEY-RSA pem exportable terminal Aussuper!
! Configure GDOI Groups
!
crypto gdoi group GWAN-GDOI-GROUP
identity number 200
server local
  rekey algorithm aes 256
  rekey lifetime second 86400
  rekey retransmit 40 number 3
  rekey authentication mypubkey rsa GETVPN-REKEY-RSA
  rekey transport unicast
  authorization address ipv4 52
  sa ipsec 10
   profile GETVPN-PROFILE
   match address ipv4 GETVPN-POLICY-ACL
   replay time window-size 5
   exit
address ipv4 <AUS-KEY-IP>
   redundancy
   local priority 140
   peer address ipv4 <AUE-KEY-IP>
!
password encryption aes