From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Bug 451804] New: kernel: KERNEL: assertion (flags & MSG_PEEK)
 failed at net/ipv4/tcp.c (1354)
Date: Tue, 17 Jun 2008 22:35:55 -0700 (PDT)
Message-ID: <20080617.223555.226018311.davem@davemloft.net>
References: <20080617144056.GA19275@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davej-rdkfGonbjUTCLXcRTR1eJlpr/1R2p/CL@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080617144056.GA19275-rdkfGonbjUTCLXcRTR1eJlpr/1R2p/CL@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej-rdkfGonbjUTCLXcRTR1eJlpr/1R2p/CL@public.gmane.org>
Date: Tue, 17 Jun 2008 10:40:56 -0400

> This one been reported yet ?

Looks to be an ath5k specific problem based upon other
reports I was able to find.

For example, have a look at the "Transfers stall with ath5k
on compat-wireless drivers" thread on the ath5k-devel list:

http://kerneltrap.org/mailarchive/linux-ath5k-devel/2008/6/4/2028874

linux-wireless added to CC.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
