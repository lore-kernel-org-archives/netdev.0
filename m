From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 10/10] vxlan: version 0.2
Date: Tue,  4 Jun 2013 21:24:14 -0700
Message-ID: <1370406254-6341-10-git-send-email-stephen@networkplumber.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:52623 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab3FEEYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:24:33 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so252550pdc.19
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:24:33 -0700 (PDT)
In-Reply-To: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a3690d4..61f04b6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -42,7 +42,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
-#define VXLAN_VERSION	"0.1"
+#define VXLAN_VERSION	"0.2"
 
 #define PORT_HASH_BITS	8
 #define PORT_HASH_SIZE  (1<<PORT_HASH_BITS)
-- 
1.7.10.4
