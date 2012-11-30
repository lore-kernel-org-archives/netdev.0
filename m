From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] MAINTAINERS: fix bouncing tun/tap entries
Date: Fri, 30 Nov 2012 18:05:40 +0100
Message-ID: <1354295140-6355-1-git-send-email-jslaby@suse.cz>
Cc: netdev@vger.kernel.org, jirislaby@gmail.com,
	linux-kernel@vger.kernel.org
To: maxk@qti.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Delivery to the following recipient failed permanently:

     vtun@office.satix.net

Technical details of permanent failure:
DNS Error: Domain name not found

Of course:
$ host office.satix.net
Host office.satix.net not found: 3(NXDOMAIN)

===========

And "Change of Email Address Notification":
Old Address        New Address           Email Subject
------------------------------------------------------
maxk@qualcomm.com  maxk@qti.qualcomm.com "tuntap: multiqueue...

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Maxim Krasnyansky <maxk@qti.qualcomm.com>
---
 MAINTAINERS | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 61b2e14..75d3b88 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7696,8 +7696,7 @@ S:	Maintained
 F:	drivers/net/ethernet/dec/tulip/
 
 TUN/TAP driver
-M:	Maxim Krasnyansky <maxk@qualcomm.com>
-L:	vtun@office.satix.net
+M:	Maxim Krasnyansky <maxk@qti.qualcomm.com>
 W:	http://vtun.sourceforge.net/tun
 S:	Maintained
 F:	Documentation/networking/tuntap.txt
-- 
1.8.0.1
