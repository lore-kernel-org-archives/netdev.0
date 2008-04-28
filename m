From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 9/9 net-next-2.6] [TIPC]: Update version number to TIPC 1.6.4
Date: Mon, 28 Apr 2008 15:48:46 -0400
Message-ID: <1209412126-2109-10-git-send-email-allan.stephens@windriver.com>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33708 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934332AbYD1TwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:08 -0400
In-Reply-To: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates TIPC's version number to 1.6.4.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 862d415..6d6aa5a 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -49,7 +49,7 @@
 #include "config.h"
 
 
-#define TIPC_MOD_VER "1.6.3"
+#define TIPC_MOD_VER "1.6.4"
 
 #ifndef CONFIG_TIPC_ZONES
 #define CONFIG_TIPC_ZONES 3
-- 
1.5.3.2

