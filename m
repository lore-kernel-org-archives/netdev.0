From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] net: correct a comment for the final #endif
Date: Wed, 27 May 2009 16:01:53 +0200
Message-ID: <20090527140153.GE1652@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42040 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758598AbZE0OBx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 10:01:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] net: correct a comment for the final #endif

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5a96a1a..aab9a4e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1910,4 +1910,4 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 extern struct pernet_operations __net_initdata loopback_net_ops;
 #endif /* __KERNEL__ */
 
-#endif	/* _LINUX_DEV_H */
+#endif	/* _LINUX_NETDEVICE_H */
