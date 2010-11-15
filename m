From: Joe Perches <joe@perches.com>
Subject: [PATCH 39/44] include/net/caif/cfctrl.h: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:04:58 -0800
Message-ID: <35914cfea1bd0ab3963e632d02b1fdd52a9d2bc8.1289789605.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1252 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932944Ab0KODGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Nov 2010 22:06:01 -0500
In-Reply-To: <cover.1289789604.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/caif/cfctrl.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/caif/cfctrl.h b/include/net/caif/cfctrl.h
index 9402543..e54f639 100644
--- a/include/net/caif/cfctrl.h
+++ b/include/net/caif/cfctrl.h
@@ -51,7 +51,7 @@ struct cfctrl_rsp {
 	void (*restart_rsp)(void);
 	void (*radioset_rsp)(void);
 	void (*reject_rsp)(struct cflayer *layer, u8 linkid,
-				struct cflayer *client_layer);;
+				struct cflayer *client_layer);
 };
 
 /* Link Setup Parameters for CAIF-Links. */
-- 
1.7.3.1.g432b3.dirty

