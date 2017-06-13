From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable] qmi_wwan: new Telewell and Sierra device IDs
Date: Tue, 13 Jun 2017 13:21:46 -0400 (EDT)
Message-ID: <20170613.132146.1171292364667084017.davem@davemloft.net>
References: <20170613171018.31526-1-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, petr_kloc-/E1597aS9LQAvxtiuMwx3w@public.gmane.org, tlikonen-X3B1VOXEql0@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170613171018.31526-1-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Tue, 13 Jun 2017 19:10:18 +0200

> A new Sierra Wireless EM7305 device ID used in a Toshiba laptop,
> and two Longcheer device IDs entries used by Telewell TW-3G HSPA+
> branded modems.
> 
> Reported-by: Petr Kloc <petr_kloc-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> Reported-by: Teemu Likonen <tlikonen-X3B1VOXEql0@public.gmane.org>
> Signed-off-by: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
> The following patch should be backported to v4.9 and later stable kernels to
> make this one apply cleanly:
> 
>  14cf4a771b30 ("drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR for Telit PID 0x1201")

Ok, applied and queued up for -stable, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
