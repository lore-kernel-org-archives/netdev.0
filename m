From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] cdc_ether: add Novatel USB551L device IDs for
 FLAG_WWAN
Date: Tue, 15 May 2012 13:42:40 -0400 (EDT)
Message-ID: <20120515.134240.876286884006063987.davem@davemloft.net>
References: <1336400691.2385.10.camel@dcbw.foobar.com>
	<201205071623.56396.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201205071623.56396.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date: Mon, 7 May 2012 16:23:56 +0200

> Am Montag, 7. Mai 2012, 16:24:51 schrieb Dan Williams:
>> Needs to be tagged with FLAG_WWAN, which since it has generic
>> descriptors, won't happen if we don't override the generic
>> driver info.
>> 
>> Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
>> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Acked-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
