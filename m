From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable] qmi_wwan: add Dell DW5811e
Date: Tue, 21 Mar 2017 17:26:04 -0700 (PDT)
Message-ID: <20170321.172604.1697971080967198520.davem@davemloft.net>
References: <20170317162048.3119-1-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170317162048.3119-1-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri, 17 Mar 2017 17:20:48 +0100

> This is a Dell branded Sierra Wireless EM7455. It is operating in
> MBIM mode by default, but can be configured to provide two QMI/RMNET
> functions.
> 
> Signed-off-by: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
> Note regarding stable backports:
> 
> This device should only be added to v4.5 and later. It depends on
> commit 32f7adf633b9 ("net: qmi_wwan: support "raw IP" mode")
> which has not been backported AFAIK.

Applied and queued up for -stable, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
