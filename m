From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 11/12] batman-adv: Fix typo 'wether' -> 'whether'
Date: Wed, 16 Dec 2015 15:49:32 +0800
Message-ID: <1450252173-20949-12-git-send-email-antonio__3794.14610001749$1450252815$gmane$org@meshcoding.com>
References: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:20360 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932447AbbLPIAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 03:00:06 -0500
In-Reply-To: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 45952dc..5dbcb2e 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -908,7 +908,7 @@ end:
  *  appropriate handlers
  * @bat_priv: the bat priv with all the soft interface information
  * @tvlv_handler: tvlv callback function handling the tvlv content
- * @ogm_source: flag indicating wether the tvlv is an ogm or a unicast packet
+ * @ogm_source: flag indicating whether the tvlv is an ogm or a unicast packet
  * @orig_node: orig node emitting the ogm packet
  * @src: source mac address of the unicast packet
  * @dst: destination mac address of the unicast packet
@@ -961,7 +961,7 @@ static int batadv_tvlv_call_handler(struct batadv_priv *bat_priv,
  * batadv_tvlv_containers_process - parse the given tvlv buffer to call the
  *  appropriate handlers
  * @bat_priv: the bat priv with all the soft interface information
- * @ogm_source: flag indicating wether the tvlv is an ogm or a unicast packet
+ * @ogm_source: flag indicating whether the tvlv is an ogm or a unicast packet
  * @orig_node: orig node emitting the ogm packet
  * @src: source mac address of the unicast packet
  * @dst: destination mac address of the unicast packet
-- 
2.6.4
