From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] MAINTAINERS: Include platform_data/mdio-gpio.h into PHY LIBRARY
Date: Fri, 28 Jul 2017 16:08:12 -0700
Message-ID: <20170728230812.29941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:38699 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752763AbdG1XIQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 19:08:16 -0400
Received: by mail-qt0-f194.google.com with SMTP id p3so14023525qtg.5
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 16:08:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include the file include/linux/platform_data/mdio-gpio.h into the PHY
LIBRARY maintainers section.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 297e610c9163..7b5834ee1260 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5140,6 +5140,7 @@ L:	netdev@vger.kernel.org
 S:	Maintained
 F:	include/linux/phy.h
 F:	include/linux/phy_fixed.h
+F:	include/linux/platform_data/mdio-gpio.h
 F:	drivers/net/phy/
 F:	Documentation/networking/phy.txt
 F:	drivers/of/of_mdio.c
-- 
2.9.3
