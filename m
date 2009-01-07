From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 03/42] bluetooth: driver API update
Date: Wed, 07 Jan 2009 02:53:52 +0100
Message-ID: <1231293232.14901.13.camel@californication>
References: <20090107003316.784424362@vyatta.com>
	 <20090107003345.753201945@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090107003345.753201945-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

> Convert to net_device_ops and use internal net_device_stats in bnep
> device. 
> 
> Note: no need for bnep_net_ioctl since if ioctl is not set, then
> dev_ifsioc handles it by returning -EOPNOTSUPP
> 
> Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

looks good to me.

Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>

Dave, I assume you take the whole series in one go, so I leave it up to
you to apply.

Regards

Marcel
