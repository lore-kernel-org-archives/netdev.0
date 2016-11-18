From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next v2 2/5] virtio_net.h: Fix comment.
Date: Fri, 18 Nov 2016 15:40:39 -0800
Message-ID: <1479512442-61601-2-git-send-email-jarno@ovn.org>
References: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:52208 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752380AbcKRXk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 18:40:57 -0500
In-Reply-To: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix incorrent comment after the final #endif.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 include/linux/virtio_net.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 1c912f8..74f1e33 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -98,4 +98,4 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 	return 0;
 }
 
-#endif /* _LINUX_VIRTIO_BYTEORDER */
+#endif /* _LINUX_VIRTIO_NET_H */
-- 
2.1.4
