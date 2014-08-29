From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 3/5] Documentation: devicetree: net: mention Marvell Berlin
Date: Fri, 29 Aug 2014 15:51:01 +0200
Message-ID: <1409320263-10295-4-git-send-email-antoine.tenart@free-electrons.com>
References: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marvell Berlin SoCs have a MDIO interface for their Ethernet
controllers. Mention Berlin in the SoC list.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 Documentation/devicetree/bindings/net/marvell-orion-mdio.txt | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
index 9417e54c26c0..4580c2256039 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -1,9 +1,9 @@
 * Marvell MDIO Ethernet Controller interface
 
 The Ethernet controllers of the Marvel Kirkwood, Dove, Orion5x,
-MV78xx0, Armada 370 and Armada XP have an identical unit that provides
-an interface with the MDIO bus. This driver handles this MDIO
-interface.
+MV78xx0, Armada 370, Armada XP and Berlin have an identical unit
+that provides an interface with the MDIO bus. This driver handles
+this MDIO interface.
 
 Required properties:
 - compatible: "marvell,orion-mdio"
-- 
1.9.1
