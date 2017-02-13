From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 1/1] MAINTAINERS: Remove old e-mail address
Date: Mon, 13 Feb 2017 14:15:44 -0300
Message-ID: <20170213171544.GD6473@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:49184 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753374AbdBMRQG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 12:16:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ghostprotocols.net domain is not working, remove it from CREDITS and
MAINTAINERS, and change the status to "Odd fixes", and since I haven't
been maintaining those, remove my address from there.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 CREDITS     |  5 ++---
 MAINTAINERS | 15 ++++++---------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/CREDITS b/CREDITS
index c58560701d13..c5626bf06264 100644
--- a/CREDITS
+++ b/CREDITS
@@ -2478,12 +2478,11 @@ S: D-90453 Nuernberg
 S: Germany
 
 N: Arnaldo Carvalho de Melo
-E: acme@ghostprotocols.net
+E: acme@kernel.org
 E: arnaldo.melo@gmail.com
 E: acme@redhat.com
-W: http://oops.ghostprotocols.net:81/blog/
 P: 1024D/9224DF01 D5DF E3BB E3C8 BCBB F8AD  841A B6AB 4681 9224 DF01
-D: IPX, LLC, DCCP, cyc2x, wl3501_cs, net/ hacks
+D: tools/, IPX, LLC, DCCP, cyc2x, wl3501_cs, net/ hacks
 S: Brazil
 
 N: Karsten Merker
diff --git a/MAINTAINERS b/MAINTAINERS
index 3960e7faaa99..b781db49d363 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -877,8 +877,8 @@ S:	Odd fixes
 F:	drivers/hwmon/applesmc.c
 
 APPLETALK NETWORK LAYER
-M:	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
-S:	Maintained
+L:	netdev@vger.kernel.org
+S:	Odd fixes
 F:	drivers/net/appletalk/
 F:	net/appletalk/
 
@@ -6727,9 +6727,8 @@ S:	Odd Fixes
 F:	drivers/tty/ipwireless/
 
 IPX NETWORK LAYER
-M:	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
 L:	netdev@vger.kernel.org
-S:	Maintained
+S:	Odd fixes
 F:	include/net/ipx.h
 F:	include/uapi/linux/ipx.h
 F:	net/ipx/
@@ -7501,8 +7500,8 @@ S:	Maintained
 F:	drivers/misc/lkdtm*
 
 LLC (802.2)
-M:	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
-S:	Maintained
+L:	netdev@vger.kernel.org
+S:	Odd fixes
 F:	include/linux/llc.h
 F:	include/uapi/linux/llc.h
 F:	include/net/llc*
@@ -13373,10 +13372,8 @@ S:	Maintained
 F:	drivers/input/misc/wistron_btns.c
 
 WL3501 WIRELESS PCMCIA CARD DRIVER
-M:	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
 L:	linux-wireless@vger.kernel.org
-W:	http://oops.ghostprotocols.net:81/blog
-S:	Maintained
+S:	Odd fixes
 F:	drivers/net/wireless/wl3501*
 
 WOLFSON MICROELECTRONICS DRIVERS
-- 
2.9.3
