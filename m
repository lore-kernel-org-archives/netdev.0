From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: [PATCH] net: remove empty lines from tcp_syn_flood_action
Date: Wed, 19 Mar 2014 15:58:24 +0200
Message-ID: <1395237505-20550-1-git-send-email-dbaluta@ixiacom.com>
Cc: dbaluta@ixiacom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/ipv4/tcp_ipv4.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c4f1d9a..4555244 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -880,8 +880,6 @@ bool tcp_syn_flood_action(struct sock *sk,
 	bool want_cookie = false;
 	struct listen_sock *lopt;
 
-
-
 #ifdef CONFIG_SYN_COOKIES
 	if (sysctl_tcp_syncookies) {
 		msg = "Sending cookies";
-- 
1.7.10.4
