From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 4/4] Documentation: net: phy: Add links to several standards documents
Date: Sun, 27 Nov 2016 18:45:15 -0800
Message-ID: <20161128024515.13070-5-f.fainelli@gmail.com>
References: <20161128024515.13070-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36021 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754103AbcK1Cp0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 21:45:26 -0500
Received: by mail-oi0-f68.google.com with SMTP id u15so11794361oie.3
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 18:45:25 -0800 (PST)
In-Reply-To: <20161128024515.13070-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add links to the IEEE 802.3-2008 document, and the RGMII v1.3 and v2.0
revisions of the standard.

Reviewed-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/phy.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index c7ba84b5d912..e017d933d530 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -407,3 +407,13 @@ Board Fixups
  The stubs set one of the two matching criteria, and set the other one to
  match anything.
 
+Standards
+
+ IEEE Standard 802.3: CSMA/CD Access Method and Physical Layer Specifications, Section Two:
+ http://standards.ieee.org/getieee802/download/802.3-2008_section2.pdf
+
+ RGMII v1.3:
+ http://web.archive.org/web/20160303212629/http://www.hp.com/rnd/pdfs/RGMIIv1_3.pdf
+
+ RGMII v2.0:
+ http://web.archive.org/web/20160303171328/http://www.hp.com/rnd/pdfs/RGMIIv2_0_final_hp.pdf
-- 
2.9.3
