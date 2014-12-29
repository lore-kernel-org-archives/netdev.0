From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [RFC PATCH 4/6] cdc_ncm: update specs URL
Date: Mon, 29 Dec 2014 11:09:46 +0100
Message-ID: <1419847788-25610-5-git-send-email-mrkiko.rs@gmail.com>
References: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:50379 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbaL2KJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 05:09:56 -0500
Received: by mail-wg0-f46.google.com with SMTP id x13so18493592wgg.5
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 02:09:55 -0800 (PST)
In-Reply-To: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just in case there is the need to reference docs.

Signed-Off-By: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index bcd9437..0970991 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -6,7 +6,7 @@
  * Original author: Hans Petter Selasky <hans.petter.selasky@stericsson.com>
  *
  * USB Host Driver for Network Control Model (NCM)
- * http://www.usb.org/developers/devclass_docs/NCM10.zip
+ * http://www.usb.org/developers/docs/devclass_docs/NCM10_012011.zip
  *
  * The NCM encoding, decoding and initialization logic
  * derives from FreeBSD 8.x. if_cdce.c and if_cdcereg.h
-- 
2.2.1
