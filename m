From: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 3.6-rc3] wlcore: Declare MODULE_FIRMWARE usage
Date: Wed, 29 Aug 2012 08:48:09 -0600
Message-ID: <1346251689-37023-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, Eyal Shapira <eyal-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cc: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
Cc: Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
Cc: Eyal Shapira <eyal-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/ti/wlcore/main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 7254860..a55ace6 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -5663,3 +5663,4 @@ MODULE_PARM_DESC(no_recovery, "Prevent HW recovery. FW will remain stuck.");
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>");
 MODULE_AUTHOR("Juuso Oikarinen <juuso.oikarinen-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>");
+MODULE_FIRMWARE(WL12XX_NVS_NAME);
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
