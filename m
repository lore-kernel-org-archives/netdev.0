From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH RESEND net-next V2 2/3] net: huawei_cdc_ncm: Introduce
 the  huawei_cdc_ncm driver
Date: Wed, 21 Aug 2013 19:56:29 -0700
Message-ID: <20130822025629.GA2874@kroah.com>
References: <mrkiko.rs@gmail.com>
 <1377138641-2765-1-git-send-email-mrkiko.rs@gmail.com>
 <1377138641-2765-3-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1377138641-2765-3-git-send-email-mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 22, 2013 at 04:30:40AM +0200, Enrico Mioso wrote:
> This driver supports devices using the NCM protocol as an encapsulation layer
> for other protocols, like the E3131 Huawei 3G modem. This driver was heavily inspired by the qmi_wwan approach & code model.

Line-wrap your changelog lines?

> 
> Suggested-by: Bjorn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Signed-off-by: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/usb/Kconfig  |   11 +++++++++++
>  drivers/net/usb/Makefile |    1 +
>  2 files changed, 12 insertions(+)

I think you forgot to add the driver to the patch :(

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
