From: Joe Perches <joe@perches.com>
Subject: [PATCH 41/44] net/ipv6/mcast.c: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:05:00 -0800
Message-ID: <1f3e1f7e454f3c62b66fc5f3e1e1ed90d62b7fb0.1289789605.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1258 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932980Ab0KODGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Nov 2010 22:06:02 -0500
In-Reply-To: <cover.1289789604.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/mcast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index d1444b9..9c50745 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -257,7 +257,7 @@ static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
 		return NULL;
 	idev = __in6_dev_get(dev);
 	if (!idev)
-		return NULL;;
+		return NULL;
 	read_lock_bh(&idev->lock);
 	if (idev->dead) {
 		read_unlock_bh(&idev->lock);
-- 
1.7.3.1.g432b3.dirty

