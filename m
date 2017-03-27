From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] MAINTAINERS: Add Andrew Lunn as co-maintainer of PHYLIB
Date: Mon, 27 Mar 2017 10:48:11 -0700
Message-ID: <20170327174811.26354-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33865 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbdC0RtB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 13:49:01 -0400
Received: by mail-wr0-f193.google.com with SMTP id w43so12558940wrb.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 10:48:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew has been contributing a lot to PHYLIB over the past months and
his feedback on patches is more than welcome.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e48678d15401..9975dcefc372 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4922,6 +4922,7 @@ F:	include/linux/netfilter_bridge/
 F:	net/bridge/
 
 ETHERNET PHY LIBRARY
+M:	Andrew Lunn <andrew@lunn.ch>
 M:	Florian Fainelli <f.fainelli@gmail.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-- 
2.9.3
