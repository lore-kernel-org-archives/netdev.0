From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: cdc_ncm: tag Huawei devices (e.g. E5331) with
 FLAG_WWAN
Date: Wed, 27 Feb 2013 13:12:02 -0500 (EST)
Message-ID: <20130227.131202.2216500246382349857.davem@davemloft.net>
References: <1361970538-24451-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361970538-24451-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Wed, 27 Feb 2013 14:08:58 +0100

> Tag all Huawei NCM devices as WWAN modems, as we don't know of any wh=
ich
> are not.  This is necessary for userspace clients to know that the de=
vice
> requires further setup on e.g. an AT-capable serial ports before
> connectivity is available.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
