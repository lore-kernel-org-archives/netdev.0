From: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Subject: IPv6 enabled Network services
Date: 13 Feb 2003 07:22:49 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030213072249.17997.qmail@webmail18.rediffmail.com>
Reply-To: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi everybody,

I have installed Red Hat Linux 2.4.18-14 on two i386 machines, 
with
kernel compiled for IPv6 support.
These machines are connected through a LAN.

when i try
telnet> 3ffe::102:304:1234/64
i get
3ffe::102:304:1234/64 unknown host

when doing ftp, same message is given.

I would like to know whether i have to configure/modify any 
scripts,
or whether these(ftp, telnet, etc) utilities are IPv6 enabled 
???

I'm eager to know what is wrong.
Please suggest me.

thanx,
San
-----------------------------------------------
