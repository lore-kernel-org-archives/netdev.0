From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Linux IP stack on kernel 2.4.18
Date: Mon, 3 Jun 2002 17:25:27 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <15611.35431.116599.261523@robur.slu.se>
References: <3CF9DDD0.3080809@galileo.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Rabeeh Khoury <rabeeh@galileo.co.il>
In-Reply-To: <3CF9DDD0.3080809@galileo.co.il>
List-Id: netdev.vger.kernel.org


Rabeeh Khoury writes:
 > 
 > 1.. How can I adjust the throttling parameter of the IP stack not to drop any packet ? Meantime the IP stack routes 55k packets/sec and all the other it just drops (I can see them by the result of netif_rx).

 Hello!

 There are no "throttling parameter" you have probably hit some of your 
 machine limits, bandwidth, CPU etc and 55 kpps can be decent. You didn't 
 mention your input rate, paket size or hardware.

 http://www.cyberus.ca/~hadi/usenix-paper.tgz

 Discusses related issues..


 Cheers.
						--ro
