From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/1] net/usb: initiate sync sequence in sierra_net.c
 driver
Date: Tue, 04 May 2010 14:53:57 -0700 (PDT)
Message-ID: <20100504.145357.111558943.davem@davemloft.net>
References: <1272497304.8835.2.camel@Linuxdev4-laptop>
	<20100501.180829.139101312.davem@davemloft.net>
	<1273004302.6718.10.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, rfiler-usJ8hg9QsBLWpu6QEFMNjNBPR1lH4CV8@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1273004302.6718.10.camel@Linuxdev4-laptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Date: Tue, 4 May 2010 13:18:22 -0700

> What are the chances of this patch to be in the kernel-2.6.34 release?
> Without this patch the driver sierra_net (currently in kernel-2.6.34-rc6) 
> will not work.

It's sitting in my net-2.6 tree which means it will go to Linus the
next time I send him a pull request.  I have no idea when that will
be, but hopefully it will be soon.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
