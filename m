From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] Doc: net: dsa: b53: update location of referenced dsa.txt
Date: Thu, 15 Jun 2017 20:59:57 +0200
Message-ID: <20170615185957.16405-1-xypron.glpk@gmx.de>
References: <20170615.144635.940189694308591273.davem@davemloft.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615.144635.940189694308591273.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The referenced file dsa.txt is located at
Documentation/devicetree/bindings/net/dsa/dsa.txt

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
Resent due to missing
Cc: netdev@vger.kernel.org
---
 Documentation/devicetree/bindings/net/dsa/b53.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/b53.txt b/Documentation/devicetree/bindings/net/dsa/b53.txt
index d6c6e41648d4..8ec2ca21adeb 100644
--- a/Documentation/devicetree/bindings/net/dsa/b53.txt
+++ b/Documentation/devicetree/bindings/net/dsa/b53.txt
@@ -34,7 +34,7 @@ Required properties:
       "brcm,bcm6328-switch"
       "brcm,bcm6368-switch" and the mandatory "brcm,bcm63xx-switch"
 
-See Documentation/devicetree/bindings/dsa/dsa.txt for a list of additional
+See Documentation/devicetree/bindings/net/dsa/dsa.txt for a list of additional
 required and optional properties.
 
 Examples:
-- 
2.11.0
