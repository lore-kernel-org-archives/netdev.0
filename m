From: Diego Viola <diego.viola-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH TRIVIAL] drivers/net/usb/plusb.c: Fix typo
Date: Sun, 27 Mar 2016 20:58:15 -0300
Message-ID: <1459123095-2673-1-git-send-email-diego.viola@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Diego Viola <diego.viola-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Diego Viola <diego.viola-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/plusb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 1bfe0fc..22e1a9a 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -38,7 +38,7 @@
  * HEADS UP:  this handshaking isn't all that robust.  This driver
  * gets confused easily if you unplug one end of the cable then
  * try to connect it again; you'll need to restart both ends. The
- * "naplink" software (used by some PlayStation/2 deveopers) does
+ * "naplink" software (used by some PlayStation/2 developers) does
  * the handshaking much better!   Also, sometimes this hardware
  * seems to get wedged under load.  Prolific docs are weak, and
  * don't identify differences between PL2301 and PL2302, much less
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
