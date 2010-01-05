From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/6] hso: Add Vendor/Product ID's for new devices
Date: Tue, 5 Jan 2010 15:50:31 +0100
Message-ID: <20100105145029.GA19825@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Add product ID's for new devices.

Signed-off-by: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

--- linux-2.6.orig/drivers/net/usb/hso.c
+++ linux-2.6/drivers/net/usb/hso.c
@@ -461,10 +461,17 @@ static const struct usb_device_id hso_id
 	{USB_DEVICE(0x0af0, 0x7501)},		/* GTM 382 */
 	{USB_DEVICE(0x0af0, 0x7601)},		/* GE40x */
 	{USB_DEVICE(0x0af0, 0x7701)},
+	{USB_DEVICE(0x0af0, 0x7706)},
 	{USB_DEVICE(0x0af0, 0x7801)},
 	{USB_DEVICE(0x0af0, 0x7901)},
+	{USB_DEVICE(0x0af0, 0x7A01)},
+	{USB_DEVICE(0x0af0, 0x7A05)},
 	{USB_DEVICE(0x0af0, 0x8200)},
 	{USB_DEVICE(0x0af0, 0x8201)},
+	{USB_DEVICE(0x0af0, 0x8300)},
+	{USB_DEVICE(0x0af0, 0x8302)},
+	{USB_DEVICE(0x0af0, 0x8304)},
+	{USB_DEVICE(0x0af0, 0x8400)},
 	{USB_DEVICE(0x0af0, 0xd035)},
 	{USB_DEVICE(0x0af0, 0xd055)},
 	{USB_DEVICE(0x0af0, 0xd155)},
@@ -473,6 +480,8 @@ static const struct usb_device_id hso_id
 	{USB_DEVICE(0x0af0, 0xd157)},
 	{USB_DEVICE(0x0af0, 0xd257)},
 	{USB_DEVICE(0x0af0, 0xd357)},
+	{USB_DEVICE(0x0af0, 0xd058)},
+	{USB_DEVICE(0x0af0, 0xc100)},
 	{}
 };
 MODULE_DEVICE_TABLE(usb, hso_ids);
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
