From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH] dt-bindings: net: renesas-ravb: Add support for R8A77995 RAVB
Date: Wed, 13 Sep 2017 21:17:40 +0900
Message-ID: <1505305060-4192-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        devicetree@vger.kernel.org,
        Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: davem@davemloft.net, robh+dt@kernel.org, mark.rutland@arm.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new compatible string for the R8A77995 (R-Car D3) RAVB.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 Documentation/devicetree/bindings/net/renesas,ravb.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
index 1672353..ae2213f 100644
--- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
+++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
@@ -17,6 +17,7 @@ Required properties:
 
       - "renesas,etheravb-r8a7795" for the R8A7795 SoC.
       - "renesas,etheravb-r8a7796" for the R8A7796 SoC.
+      - "renesas,etheravb-r8a77995" for the R8A77995 SoC.
       - "renesas,etheravb-rcar-gen3" as a fallback for the above
 		R-Car Gen3 devices.
 
-- 
1.9.1
