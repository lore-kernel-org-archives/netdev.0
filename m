From: =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>
Subject: [PATCH v2] MAINTAINERS: Add device tree bindings to mv88e6xx section
Date: Sun, 27 Nov 2016 22:07:30 +0100
Message-ID: <1480280850-10409-1-git-send-email-afaerber@suse.de>
References: <1480280676-10117-1-git-send-email-afaerber@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-arm-kernel@lists.infradead.org,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        =?UTF-8?q?Bed=C5=99icha=20Ko=C5=A1atu?= <bedrich.kosata@nic.cz>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54302 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752379AbcK0VHf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 16:07:35 -0500
In-Reply-To: <1480280676-10117-1-git-send-email-afaerber@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also include the netdev list for convenience, as done elsewhere.

Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Andreas Färber <afaerber@suse.de>
---
 MAINTAINERS | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index f73e19277a70..677d73cfedc7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7668,8 +7668,10 @@ S:	Maintained
 MARVELL 88E6XXX ETHERNET SWITCH FABRIC DRIVER
 M:	Andrew Lunn <andrew@lunn.ch>
 M:	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/dsa/mv88e6xxx/
+F:	Documentation/devicetree/bindings/net/dsa/marvell.txt
 
 MARVELL ARMADA DRM SUPPORT
 M:	Russell King <rmk+kernel@armlinux.org.uk>
-- 
2.6.6
