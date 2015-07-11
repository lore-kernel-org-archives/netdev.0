From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] cdc_ncm: update specs URL
Date: Sat, 11 Jul 2015 17:30:01 +0200
Message-ID: <1436628601-14315-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Update referenced specs link to reflect actual file version and location.

Signed-off-by: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 1991e4a..db40175 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -6,7 +6,7 @@
  * Original author: Hans Petter Selasky <hans.petter.selasky-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
  *
  * USB Host Driver for Network Control Model (NCM)
- * http://www.usb.org/developers/devclass_docs/NCM10.zip
+ * http://www.usb.org/developers/docs/devclass_docs/NCM10_012011.zip
  *
  * The NCM encoding, decoding and initialization logic
  * derives from FreeBSD 8.x. if_cdce.c and if_cdcereg.h
-- 
2.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
