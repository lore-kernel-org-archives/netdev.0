From: <Rezwanul_Kabir@Dell.com>
Subject: RE: ioctl() to get MAC address from EEPROM
Date: Tue, 7 Sep 2004 16:55:00 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <06226F23984D7A49A694576CF06603F908BBCE@ausx2kmpc106.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 Any comments on below?
 If this is not the right forum  to ask such questions, could anyone pls point me to an appropriate forum?
 I really need to figure out the best way to do it...
 Thanks..
     --rez

>  -----Original Message-----
> From: 	Kabir, Rezwanul  
> Sent:	Friday, September 03, 2004 12:06 PM
> To:	netdev@oss.sgi.com
> Subject:	ioctl() to get MAC address from EEPROM
> 
> 
> Hi
> 
>     There seems to be no standard way to retrieve the MAC 
> address of a NIC stored in the EEPROM ( ETHTOOL_GEEPROM ioctl 
> may be used to do such thing but there's a need for a more 
> direct standard interface).This is sometimes necessary when 
> the MAC address in EEPROM may differ from the one associated 
> with the software interface (i.e. dev_addr in struct 
> net_device).For example, in some modes of channel bonding , 
> the MAC address of the active NIC is duplicated on the rest 
> of the members of the specific bond/team. How to fetch the 
> "permanent" MAC address in this case?
>     Any plan to include such commands in ethtool ioctls? Is 
> there  a better way to do this?
>     Any suggestions would be appreciated..
>     Thanks..
>          --rez
> 
> 
>  
