From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/16] batman-adv: Remove space before semicolon
Date: Mon,  2 Jul 2012 01:43:43 +0200
Message-ID: <1341186226-10549-14-git-send-email-ordex@autistici.org>
References: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23607 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981Ab2GAXnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:43 -0400
In-Reply-To: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hash.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 0759c70..15a849c 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -25,7 +25,7 @@ static void batadv_hash_init(struct batadv_hashtable *hash)
 {
 	uint32_t i;
 
-	for (i = 0 ; i < hash->size; i++) {
+	for (i = 0; i < hash->size; i++) {
 		INIT_HLIST_HEAD(&hash->table[i]);
 		spin_lock_init(&hash->list_locks[i]);
 	}
-- 
1.7.9.4
