From: "Larry Sendlosky" <Larry.Sendlosky@storigen.com>
Subject: 2.4.20, tg3 , and 5704
Date: Mon, 16 Dec 2002 12:59:54 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7BFCE5F1EF28D64198522688F5449D5A03C0CE@xchangeserver2.storigen.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

I got a preproduction Dell server with 2 5704 NICs
onboard. 2.4.20 w/tg3 doesn't want to work. When loaded
the link light on the switch just goes on-off-on-off ...
seeming like it is reinitializing all the time. 

I just did get the current Broadcom drivers sources and
it seems to work ok (ping and ftp works on 100Mb ...)
built against 2.4.20.

I prefer to use tg3 even though I have to backport
to 2.4.18 (not a big fan of the Broadcom code and
it's not part of linux).

thanks for any help

larry
