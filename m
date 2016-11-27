From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/4] Documentation: net: phy: Add links to several standards documents
Date: Sun, 27 Nov 2016 10:44:49 -0800
Message-ID: <20161127184449.12351-5-f.fainelli@gmail.com>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34450 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753042AbcK0So7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 13:44:59 -0500
Received: by mail-oi0-f66.google.com with SMTP id m75so10882293oig.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 10:44:59 -0800 (PST)
In-Reply-To: <20161127184449.12351-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add links to the IEEE 802.3-2008 document, and the RGMII v1.3 and v2.0
revisions of the standard.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/phy.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 7a0cb1212b9e..6734cf1f64d4 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -406,3 +406,13 @@ Board Fixups
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
