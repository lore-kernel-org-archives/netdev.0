From: David Miller <davem@davemloft.net>
Subject: please type "make"
Date: Sat, 05 Aug 2006 21:14:49 -0700 (PDT)
Message-ID: <20060805.211449.61357275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17087
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751231AbWHFEOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 00:14:38 -0400
To: Diego Calleja <diegocg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


on any patches you submit.  I'm fixing it this time, but I
won't next time.

Thanks.

net/lapb/lapb_iface.c: In function $,1rx(Blapb_setparms$,1ry(B:
net/lapb/lapb_iface.c:292: warning: ISO C90 forbids mixed declarations and code
net/lapb/lapb_iface.c:430: error: non-static declaration of $,1rx(Blapb_connect_request$,1ry(B follows static declaration
net/lapb/lapb_iface.c:265: error: previous definition of $,1rx(Blapb_connect_request$,1ry(B was here
net/lapb/lapb_iface.c:431: error: non-static declaration of $,1rx(Blapb_disconnect_request$,1ry(B follows static declaration
net/lapb/lapb_iface.c:295: error: previous definition of $,1rx(Blapb_disconnect_request$,1ry(B was here
net/lapb/lapb_iface.c:432: error: non-static declaration of $,1rx(Blapb_data_request$,1ry(B follows static declaration
net/lapb/lapb_iface.c:347: error: previous definition of $,1rx(Blapb_data_request$,1ry(B was here
net/lapb/lapb_iface.c:433: error: non-static declaration of $,1rx(Blapb_data_received$,1ry(B follows static declaration
net/lapb/lapb_iface.c:368: error: previous definition of $,1rx(Blapb_data_received$,1ry(B was here
net/lapb/lapb_iface.c:436: error: invalid storage class for function $,1rx(Blapb_init$,1ry(B
net/lapb/lapb_iface.c:441: error: invalid storage class for function $,1rx(Blapb_exit$,1ry(B
net/lapb/lapb_iface.c:449: error: initializer element is not constant
net/lapb/lapb_iface.c:449: warning: ISO C90 forbids mixed declarations and code
net/lapb/lapb_iface.c:450: error: initializer element is not constant
net/lapb/lapb_iface.c:450: warning: ISO C90 forbids mixed declarations and code
net/lapb/lapb_iface.c:450: error: syntax error at end of input
make[2]: *** [net/lapb/lapb_iface.o] Error 1
make[1]: *** [net/lapb] Error 2
make: *** [net] Error 2
