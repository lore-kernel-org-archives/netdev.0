From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] MAINTAINERS: PHY: Change maintainer to reviewer
Date: Tue, 24 Nov 2015 15:29:50 -0800
Message-ID: <1448407790-22336-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34291 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932357AbbKXXa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 18:30:56 -0500
Received: by padhx2 with SMTP id hx2so36698229pad.1
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 15:30:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that there is a reviewer role, add myself as reviewer since the PHY
library code is maintained via the networking tree.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ea1751283b49..950c321eef73 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4195,7 +4195,7 @@ F:	include/linux/netfilter_bridge/
 F:	net/bridge/
 
 ETHERNET PHY LIBRARY
-M:	Florian Fainelli <f.fainelli@gmail.com>
+R:	Florian Fainelli <f.fainelli@gmail.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	include/linux/phy.h
-- 
2.1.0
