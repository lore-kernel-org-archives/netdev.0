From: "Rudolf Ladyzhenskii" <Rudolf.ladyzhenskii@opennw.com>
Subject: RE: Required resources on network driver programming
Date: Tue, 21 Dec 2004 08:34:10 +1100
Message-ID: <a351964842ab19a53c7f27f1346884b341c74577@opennw.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "linux lover" <linux_lover2004@yahoo.com>, <linux-net@vger.kernel.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Firstly, there is a software package called ETHEREAL that will do that for you. 

If you really want to do it yourself, search the web on how to interface with NETFILTER.

Rudolf

-----Original Message-----
From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com]On
Behalf Of linux lover
Sent: Monday, December 20, 2004 6:46 PM
To: linux-net@vger.kernel.org
Cc: netdev@oss.sgi.com
Subject: Required resources on network driver programming


 
Hi all,
                  I am newbie to Linux kernel
programming. I want to write my own virtual network
device driver that take every packets from IP layer
just print the contents of packet(header part with its
starting addresses only) and send it to actual device
driver for packet transmission and at receiving end
receive packet from NIC card again print the header
addresses and send it to upper layer for normal packet
processing.
                 I require help about where can i get
resources or any book for writing virtual network
driver with SAMPLE EXAMPLES?
regards,
linux_lover


		
__________________________________ 
Do you Yahoo!? 
Send holiday email and support a worthy cause. Do good. 
http://celebrity.mail.yahoo.com
