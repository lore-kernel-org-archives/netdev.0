From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] cdc-ncm: tag Ericsson WWAN devices (eg F5521gw) with
 FLAG_WWAN
Date: Tue, 24 Jul 2012 13:57:50 -0700 (PDT)
Message-ID: <20120724.135750.887233508592333912.davem@davemloft.net>
References: <1343155402.29196.7.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org
To: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1343155402.29196.7.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Tue, 24 Jul 2012 13:43:22 -0500

> Tag Ericsson NCM devices as WWAN modems, since they almost certainly all
> are.  This way userspace clients know that the device requires further
> setup on the AT-capable serial ports before connectivity is available.
> 
> Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
