From: Luis Henriques <luis.henriques-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Stable request 9374e7d2 "rtlwifi: rtl8192cu: Add new device ID"
Date: Mon, 4 May 2015 10:19:35 +0100
Message-ID: <20150504091935.GD1792@ares.olymp>
References: <1430230954.6036.4@alarsen-lx>
 <201504281633.17160.marex@denx.de>
 <553FA5F0.1070402@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Marek Vasut <marex-ynQEQJNshbs@public.gmane.org>,
	Anders Larsen <al-V9/YLgxv/GvR7s880joybQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <553FA5F0.1070402-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 28, 2015 at 10:23:28AM -0500, Larry Finger wrote:
> Please note that there are two commits just added to the mainline rep=
o that
> should be propagated to all stable kernels. Both are addition of new =
USB IDs
> for an old driver, thus they will cause to side effects. Unfortunatel=
y, the
> Cc to stable was missed in the first of these, thus the need for this
> message. The second was Cc for stable, but I include it here for
> completeness.
>=20
> The two commits in question are
>=20
> commit 9374e7d2fdcad3c36dafc8d3effd554bc702c4b6
> Author: Marek Vasut <marex-ynQEQJNshbs@public.gmane.org>
> Date:   Thu Mar 26 02:16:06 2015 +0100
>=20
>     rtlwifi: rtl8192cu: Add new device ID
>=20
>     Add new ID for ASUS N10 WiFi dongle.
>=20
> commit 2f92b314f4daff2117847ac5343c54d3d041bf78
> Author: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Date:   Mon Mar 23 18:14:10 2015 -0500
>=20
>     rtlwifi: rtl8192cu: Add new USB ID
>=20
>     USB ID 2001:330d is used for a D-Link DWA-131.
>=20
>

Thank you, Larry.  Queuing both patches for the 3.16 kernel.

Cheers,
--
Lu=EDs

> Thanks,
>=20
> Larry
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe stable" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
