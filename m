From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH net v4 1/3] dt-bindings: add SFF vendor prefix
Date: Thu,  7 Sep 2017 12:25:48 +0300
Message-ID: <b98ac3e8cde5c99489e8dcee9a1d5b8a19face8d.1504776350.git.baruch@tkos.co.il>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Baruch Siach <baruch@tkos.co.il>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:47768 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754509AbdIGJ1q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 05:27:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Rob Herring <robh@kernel.org>
Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
v4: No change

v3: Add Rob's ack

v2: New patch in this series
---
 Documentation/devicetree/bindings/vendor-prefixes.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Documentation/devicetree/bindings/vendor-prefixes.txt
index 4e72012928b4..12b5808b82f2 100644
--- a/Documentation/devicetree/bindings/vendor-prefixes.txt
+++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
@@ -289,6 +289,7 @@ schindler	Schindler
 seagate	Seagate Technology PLC
 semtech	Semtech Corporation
 sensirion	Sensirion AG
+sff	Small Form Factor Committee
 sgx	SGX Sensortech
 sharp	Sharp Corporation
 si-en	Si-En Technology Ltd.
-- 
2.14.1
