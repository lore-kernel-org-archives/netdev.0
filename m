From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: add TP-LINK HSUPA Modem MA180
Date: Wed, 16 Jan 2013 16:16:51 -0500 (EST)
Message-ID: <20130116.161651.1287342415553715660.davem@davemloft.net>
References: <201301122122.07307.tschaefer@t-online.de>
	<1358241591-29553-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lhs-AjPhSE91YUE@public.gmane.org,
	tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358241591-29553-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Tue, 15 Jan 2013 10:19:50 +0100

> The driver description files gives these names to the vendor specific
> functions on this modem:
>=20
>  Diagnostics VID_2357&PID_0201&MI_00
>  NMEA        VID_2357&PID_0201&MI_01
>  Modem       VID_2357&PID_0201&MI_03
>  Networkcard VID_2357&PID_0201&MI_04
>=20
> The "Networkcard" function has been verified to support these QMI
> services:
>     ctl (1.3)
>     wds (1.3)
>     dms (1.2)
>     nas (1.0)
>=20
> Reported-by: Thomas Sch=E4fer <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
