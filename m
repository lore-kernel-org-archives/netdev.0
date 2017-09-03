From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH v3 1/3] dt-bindings: add SFF vendor prefix
Date: Sun,  3 Sep 2017 15:31:12 +0300
Message-ID: <c2a27566a8eb358ee2566a213c385d0bf3d64307.1504441874.git.baruch@tkos.co.il>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Baruch Siach <baruch@tkos.co.il>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:47266 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753149AbdICMcP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 08:32:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Rob Herring <robh@kernel.org>
Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
v3: Add Rob's ack
v2: New patch in this series
---
 Documentation/devicetree/bindings/vendor-prefixes.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Documentation/devicetree/bindings/vendor-prefixes.txt
index daf465bef758..20fdb79a92d4 100644
--- a/Documentation/devicetree/bindings/vendor-prefixes.txt
+++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
@@ -287,6 +287,7 @@ schindler	Schindler
 seagate	Seagate Technology PLC
 semtech	Semtech Corporation
 sensirion	Sensirion AG
+sff	Small Form Factor Committee
 sgx	SGX Sensortech
 sharp	Sharp Corporation
 si-en	Si-En Technology Ltd.
-- 
2.14.1
