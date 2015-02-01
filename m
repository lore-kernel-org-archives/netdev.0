From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 00/11] hso: fix some problems in the disconnect path
Date: Sun, 01 Feb 2015 12:33:49 -0800 (PST)
Message-ID: <20150201.123349.1576470970822644717.davem@davemloft.net>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
	<1422620523-15021-1-git-send-email-olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422620523-15021-1-git-send-email-olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Date: Fri, 30 Jan 2015 13:21:52 +0100

> These patches attempt to fix some problems I observed when the hso
> device is disconnected.
> Several patches of this serie are fixing crashes or memleaks when a
> hso device is disconnected.
> This serie of patches is based on v3.18.
> 
> changes in v2:
>  - Last patch of the serie dropped since another patch fix the issue.
>    See http://marc.info/?l=linux-usb&m=142186699418489 for more info.
> 
>  - Added an extra patch avoiding name conflicts for the rfkill interface.

Series applied to net-next, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
