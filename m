From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/5] CDC: common parser for extra headers
Date: Tue, 15 Sep 2015 12:43:58 -0700 (PDT)
Message-ID: <20150915.124358.1140618858928061252.davem@davemloft.net>
References: <1441634742-19856-1-git-send-email-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org
To: oneukum-IBi9RG/b67k@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441634742-19856-1-git-send-email-oneukum-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Date: Mon,  7 Sep 2015 16:05:38 +0200

> CDC drivers all implement their own parser for the extra headers.
> This patch fixes the code duplication introducing a single common
> parser in usbnet.
> 
> Signed-off-by: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
