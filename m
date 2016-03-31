From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/1] net: usb: cdc_ncm: adding Telit LE910 V2 mobile
 broadband card
Date: Thu, 31 Mar 2016 17:20:01 -0400 (EDT)
Message-ID: <20160331.172001.764774035086904092.davem@davemloft.net>
References: <1459430207-11757-2-git-send-email-dnlplm@gmail.com>
	<20160331.165138.1846092223088368562.davem@davemloft.net>
	<87lh4ycq5p.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87lh4ycq5p.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Thu, 31 Mar 2016 23:07:30 +0200

> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
>> From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Thu, 31 Mar 2016 15:16:47 +0200
>>
>>> Telit LE910 V2 is a mobile broadband card with no ARP capabilities:
>>> the patch makes this device to use wwan_noarp_info struct
>>>=20
>>> Signed-off-by: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> Bjorn, can you take a quick look at this?
>=20
> Looks fine to me.
>=20
> Reviewed-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Thanks, applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
