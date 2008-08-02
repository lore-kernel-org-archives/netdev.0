From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-01
Date: Fri, 01 Aug 2008 22:16:04 -0700 (PDT)
Message-ID: <20080801.221604.149076257.davem@davemloft.net>
References: <20080801205830.GA10071@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080801205830.GA10071-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 1 Aug 2008 16:58:30 -0400

> Another big batch of wireless fixes for 2.6.27.  The ath5k series is
> more than fixes, but I included it because it enables new ath5k
> hardware.  (The ath5k.h changes in particular are documentation cleanups
> for registers based on info gleaned from the newly posted ath9k driver.)
> The others patches are fixes, some more obvious than others. :-)
> 
> Let me know if there are any problems!

Pulled and pushed out to net-2.6 on kernel.org

If someone could fix up this warning I'd appreciate it:

drivers/net/wireless/rt2x00/rt73usb.c: In function 'rt73usb_load_firmware':
drivers/net/wireless/rt2x00/rt73usb.c:916: warning: passing argument 5 of 'rt2x00usb_vendor_request_large_buff' discards qualifiers from pointer target type

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
