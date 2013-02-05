From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH] wpan: whitespace fix
Date: Tue,  5 Feb 2013 15:25:35 +0100
Message-ID: <1360074335-17418-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	davem@davemloft.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:58774 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459Ab3BEOZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 09:25:04 -0500
Received: by mail-ee0-f47.google.com with SMTP id e52so121840eek.6
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 06:25:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/mac802154/wpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 199b922..98c867b 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -41,7 +41,7 @@ static inline int mac802154_fetch_skb_u8(struct sk_buff *skb, u8 *val)
 		return -EINVAL;
 
 	*val = skb->data[0];
-	 skb_pull(skb, 1);
+	skb_pull(skb, 1);
 
 	return 0;
 }
-- 
1.8.1.2
