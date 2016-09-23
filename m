From: <sean.wang@mediatek.com>
Subject: [PATCH net-next] Documentation: devicetree: fix typo in MediaTek ethernet device-tree binding
Date: Fri, 23 Sep 2016 14:09:32 +0800
Message-ID: <1474610972-14974-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <john@phrozen.org>,
        <keyhaede@gmail.com>, <objelf@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <davem@davemloft.net>, <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:42831 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755932AbcIWGJq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 02:09:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

fix typo in
Documentation/devicetree/bindings/net/mediatek-net.txt

Cc: devicetree@vger.kernel.org
Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 Documentation/devicetree/bindings/net/mediatek-net.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index 7111278..f095257 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -34,7 +34,7 @@ Required properties:
 - phy-handle: see ethernet.txt file in the same directory and
 	the phy-mode "trgmii" required being provided when reg
 	is equal to 0 and the MAC uses fixed-link to connect
-	with inernal switch such as MT7530.
+	with internal switch such as MT7530.
 
 Example:
 
-- 
1.9.1
