From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable-3.8] net: cdc_mbim: remove bogus sizeof()
Date: Tue, 16 Apr 2013 16:42:05 -0400 (EDT)
Message-ID: <20130416.164205.1278259494886221635.davem@davemloft.net>
References: <1366107427-18380-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1366107427-18380-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Tue, 16 Apr 2013 12:17:07 +0200

> The intention was to test against the constant, not the size of
> the constant.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
