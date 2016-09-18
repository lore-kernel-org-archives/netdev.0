From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next] MAINTAINERS: Add an entry for the core network DSA code
Date: Sun, 18 Sep 2016 21:17:19 +0200
Message-ID: <1474226240-8083-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51526 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756172AbcIRTSO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 15:18:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The core distributed switch architecture code currently does not have
a MAINTAINERS entry, which results in some contributions not landing
in the right peoples inbox.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Add include/net/dsa.h and drivers/net/dsa/

 MAINTAINERS | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index ce80b36aab69..8c8a2e40bdbb 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8169,6 +8169,15 @@ S:	Maintained
 W:	https://fedorahosted.org/dropwatch/
 F:	net/core/drop_monitor.c
 
+NETWORKING [DSA]
+M:	Andrew Lunn <andrew@lunn.ch>
+M:	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+M:	Florian Fainelli <f.fainelli@gmail.com>
+S:	Maintained
+F:	net/dsa/
+F:	include/net/dsa.h
+F:	drivers/net/dsa/
+
 NETWORKING [GENERAL]
 M:	"David S. Miller" <davem@davemloft.net>
 L:	netdev@vger.kernel.org
-- 
2.9.3
