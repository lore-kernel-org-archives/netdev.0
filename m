From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 14/14] [TIPC] Updated TIPC version number to 1.6.2
Date: Fri, 13 Oct 2006 13:37:55 +0200
Message-ID: <11607394762079-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:50592 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751402AbWJMLiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:03 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 7f3f693..6f5b7ee 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -57,7 +57,7 @@ void tipc_socket_stop(void);
 int  tipc_netlink_start(void);
 void tipc_netlink_stop(void);
 
-#define TIPC_MOD_VER "1.6.1"
+#define TIPC_MOD_VER "1.6.2"
 
 #ifndef CONFIG_TIPC_ZONES
 #define CONFIG_TIPC_ZONES 3
-- 
1.4.1

