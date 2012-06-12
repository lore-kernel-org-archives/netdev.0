From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/7] usbnet: misc cleanup
Date: Tue, 12 Jun 2012 09:19:38 +0800
Message-ID: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patchset does some cleanup on usbnet.

 drivers/net/usb/cdc-phonet.c |    4 +--
 drivers/net/usb/pegasus.c    |    4 ---
 drivers/net/usb/usbnet.c     |   81 +++++++++++++++++++-----------------------
 include/linux/usb/usbnet.h   |    4 +--
 4 files changed, 38 insertions(+), 55 deletions(-)


Thanks,
--
Ming Lei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
