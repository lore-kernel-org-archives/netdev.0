From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: Added new USB id for Planex GW-US54ZGL
Date: Tue,  1 May 2007 04:02:59 +0100 (BST)
Message-ID: <20070501030300.01A547B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>

Alan Tam <Tam at SiuLung dot com> asked for inclusion of this
device into the tree.

Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
index 4212310..b22d908 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
@@ -65,6 +65,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0586, 0x3410), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0baf, 0x0121), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0586, 0x3412), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0053, 0x5301), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
-- 
1.5.1.2
