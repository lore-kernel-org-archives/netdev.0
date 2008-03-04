From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 1/7 net-2.6.26] [TIPC]: Update version to 1.6.3
Date: Tue,  4 Mar 2008 16:20:13 -0500
Message-ID: <1204665619-6345-2-git-send-email-allan.stephens@windriver.com>
References: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48047 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754427AbYCDVgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 16:36:08 -0500
In-Reply-To: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates TIPC's version number to 1.6.3.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index d2d7d32..9b9429e 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -57,7 +57,7 @@ void tipc_socket_stop(void);
 int  tipc_netlink_start(void);
 void tipc_netlink_stop(void);
 
-#define TIPC_MOD_VER "1.6.2"
+#define TIPC_MOD_VER "1.6.3"
 
 #ifndef CONFIG_TIPC_ZONES
 #define CONFIG_TIPC_ZONES 3
-- 
1.5.3.2

