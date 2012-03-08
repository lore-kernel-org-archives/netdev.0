From: pablo@netfilter.org
Subject: [PATCH 11/23] netfilter: nf_ct_ecache: trailing whitespace removed
Date: Thu,  8 Mar 2012 02:01:00 +0100
Message-ID: <1331168472-5820-12-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56112 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584Ab2CHBBd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2012 20:01:33 -0500
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Zelenoff <antonz@parallels.com>

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_ecache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 14af632..aa15977 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -70,7 +70,7 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 			else
 				e->missed &= ~missed;
 			spin_unlock_bh(&ct->lock);
-		} 
+		}
 	}
 
 out_unlock:
-- 
1.7.7.3
