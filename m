From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/13] batman-adv: remove duplicated line in comment
Date: Wed, 18 Apr 2012 11:59:59 +0200
Message-ID: <1334743210-12338-3-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:24550 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab2DRJ7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:24 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove an accidentally added duplicated line in a function comment

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 1cf18ac..c8642b5 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -735,7 +735,6 @@ static int handle_claim(struct bat_priv *bat_priv,
 
 /**
  * @bat_priv: the bat priv with all the soft interface information
- * @bat_priv: the bat priv with all the soft interface information
  * @hw_src: the Hardware source in the ARP Header
  * @hw_dst: the Hardware destination in the ARP Header
  * @ethhdr: pointer to the Ethernet header of the claim frame
-- 
1.7.9.4
