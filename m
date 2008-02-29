From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: [PATCH 01/08 net-2.6.26] [TIPC]: Update version to 1.6.3
Date: Fri, 29 Feb 2008 10:40:41 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0252DE20@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51578 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758542AbYB2Skm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 13:40:42 -0500
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id m1TIeg8d012179
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 10:40:42 -0800 (PST)
Content-class: urn:content-classes:message
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
