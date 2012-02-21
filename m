From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH rhel6 1/3] net/netfilter: whitespace removed
Date: Tue, 21 Feb 2012 21:26:29 +0400
Message-ID: <1329845191-484662-2-git-send-email-antonz@parallels.com>
References: <1329845191-484662-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:55551 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424Ab2BUR0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:26:35 -0500
In-Reply-To: <1329845191-484662-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
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
1.7.1
