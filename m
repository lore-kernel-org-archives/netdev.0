From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 3/5] ieee802154: it's IEEE 802.15.4, not ZigBee
Date: Thu, 30 Jun 2011 16:37:46 +0400
Message-ID: <1309437468-31021-4-git-send-email-dbaryshkov@gmail.com>
References: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37174 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149Ab1F3MiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 08:38:11 -0400
Received: by mail-wy0-f174.google.com with SMTP id 8so1510445wyg.19
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 05:38:11 -0700 (PDT)
In-Reply-To: <1309437468-31021-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/dgram.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 1a3334c..faecf64 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -1,5 +1,5 @@
 /*
- * ZigBee socket interface
+ * IEEE 802.15.4 dgram socket interface
  *
  * Copyright 2007, 2008 Siemens AG
  *
-- 
1.7.5.4

