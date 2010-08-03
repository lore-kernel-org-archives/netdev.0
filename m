From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] hso:  Add new product ID
Date: Tue, 03 Aug 2010 17:36:41 +0200
Message-ID: <1280849801.5149.5.camel@filip-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a new product ID to the hso driver.

Signed-off-by: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 4dd2351..041f0e3 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -478,6 +478,7 @@ static const struct usb_device_id hso_ids[] = {
 	{USB_DEVICE(0x0af0, 0x8600)},
 	{USB_DEVICE(0x0af0, 0x8800)},
 	{USB_DEVICE(0x0af0, 0x8900)},
+	{USB_DEVICE(0x0af0, 0x9000)},
 	{USB_DEVICE(0x0af0, 0xd035)},
 	{USB_DEVICE(0x0af0, 0xd055)},
 	{USB_DEVICE(0x0af0, 0xd155)},

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
