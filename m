From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 1/1] net: usb: cdc_ncm: adding Telit LE910 V2 mobile broadband card
Date: Thu, 31 Mar 2016 23:07:30 +0200
Message-ID: <87lh4ycq5p.fsf@nemi.mork.no>
References: <1459430207-11757-1-git-send-email-dnlplm@gmail.com>
	<1459430207-11757-2-git-send-email-dnlplm@gmail.com>
	<20160331.165138.1846092223088368562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160331.165138.1846092223088368562.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Thu, 31 Mar 2016 16:51:38 -0400 (EDT)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
> From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Thu, 31 Mar 2016 15:16:47 +0200
>
>> Telit LE910 V2 is a mobile broadband card with no ARP capabilities:
>> the patch makes this device to use wwan_noarp_info struct
>>=20
>> Signed-off-by: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> Bjorn, can you take a quick look at this?

Looks fine to me.

Reviewed-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
