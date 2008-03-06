From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 7/7 net-2.6.26] [TIPC]: Update version to 1.6.3
Date: Thu,  6 Mar 2008 16:34:29 -0500
Message-ID: <1204839269-30593-8-git-send-email-allan.stephens@windriver.com>
References: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55398 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764293AbYCFVu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 16:50:29 -0500
In-Reply-To: <1204839269-30593-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates TIPC's version number to 1.6.3.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index b41b0ac..740aac5 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -49,7 +49,7 @@
 #include "config.h"
 
 
-#define TIPC_MOD_VER "1.6.2"
+#define TIPC_MOD_VER "1.6.3"
 
 #ifndef CONFIG_TIPC_ZONES
 #define CONFIG_TIPC_ZONES 3
-- 
1.5.3.2

