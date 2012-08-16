From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH] smsc75xx: add missing entry to MAINTAINERS
Date: Thu, 16 Aug 2012 08:53:38 +0100
Message-ID: <1345103618-22753-1-git-send-email-steve.glendinning@shawell.net>
Cc: netdev@vger.kernel.org, trivial@rustcorp.com.au,
	Steve Glendinning <steve.glendinning@shawell.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 MAINTAINERS |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index f875890..560bd30 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7289,6 +7289,12 @@ W:	http://www.connecttech.com
 S:	Supported
 F:	drivers/usb/serial/whiteheat*
 
+USB SMSC75XX ETHERNET DRIVER
+M:	Steve Glendinning <steve.glendinning@shawell.net>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/usb/smsc75xx.*
+
 USB SMSC95XX ETHERNET DRIVER
 M:	Steve Glendinning <steve.glendinning@shawell.net>
 L:	netdev@vger.kernel.org
-- 
1.7.9.5
