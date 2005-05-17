From: cranium2003 <cranium2003@yahoo.com>
Subject: net_device structure help
Date: Tue, 17 May 2005 02:55:31 -0700 (PDT)
Message-ID: <20050517095531.1326.qmail@web41426.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: net dev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
        Is there any way in linux kernel network stack
at IP layer before adding IP header to know that
packet is transmitted to eth1 or forwarded to eth1 if
linux machine has 2 NIC's eth0 and eth1?
       I check net_device structre and found that
ifindex is the field that gives proper incoming packet
network interface at IP layer but same for packet
trasmission not works.
regards,
cranium



		
Yahoo! Mail
Stay connected, organized, and protected. Take the tour:
http://tour.mail.yahoo.com/mailtour.html
