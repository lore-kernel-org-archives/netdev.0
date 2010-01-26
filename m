From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/21] net/atm/addr.c: Convert include <asm to include <linux
Date: Tue, 26 Jan 2010 13:40:01 -0800
Message-ID: <d7c30ff645215f37a083cea251f2edec7d479211.1264541548.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1473 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753847Ab0AZVkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:22 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/addr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/atm/addr.c b/net/atm/addr.c
index 82e85ab..cf3ae8b 100644
--- a/net/atm/addr.c
+++ b/net/atm/addr.c
@@ -4,7 +4,7 @@
 
 #include <linux/atm.h>
 #include <linux/atmdev.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 #include "signaling.h"
 #include "addr.h"
-- 
1.6.6.rc0.57.gad7a

