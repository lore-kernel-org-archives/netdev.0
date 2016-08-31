From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V2] rtl_bt: Add firmware and config file for RTL8822BE
Date: Wed, 31 Aug 2016 02:40:32 +0100
Message-ID: <1472607632.25374.44.camel@decadent.org.uk>
References: <1472605864-4197-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-ViVrOBgV0i4J1JeyUTym"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        =?UTF-8?Q?=E9=99=86=E6=9C=B1=E4=BC=9F?= <alex_lu@realsil.com.cn>,
        linux-bluetooth@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>, linux-firmware@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35466 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751515AbcHaBkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 21:40:45 -0400
In-Reply-To: <1472605864-4197-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ViVrOBgV0i4J1JeyUTym
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-08-30 at 20:11 -0500, Larry Finger wrote:
> This device is a new model from Realtek. Updates to driver btrtl will
> soon be submitted to the kernel.
>=20
> These files were provided by the Realtek developer.
>=20
> Signed-off-by: =E9=99=86=E6=9C=B1=E4=BC=9F <alex_lu@realsil.com.cn>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: linux-bluetooth@vger.kernel.org
> ---
>=20
> V2 - fix error in file names in WHENCE
> ---
[...]
> =C2=A0Found in vendor driver, linux_bt_usb_2.11.20140423_8723be.rar
> =C2=A0From https://github.com/troy-tan/driver_store
> +Files rtl_bt/rtl8822e_* came directly from Realtek.
[...]

You missed this wildcard, but I fixed it up. =C2=A0Applied and pushed,
thanks.

Ben.

--=20
Ben Hutchings
Anthony's Law of Force: Don't force it, get a larger hammer.

--=-ViVrOBgV0i4J1JeyUTym
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJXxjWQAAoJEOe/yOyVhhEJm38P/jBMd5Y3b1YxkG9Ky6wCkBfA
Hq0UW6XaZfP/QoRTUXQ+YvWDJY0Dl3q3snQUlENriOM2YmUPxDRpbE/JWd0/BpI6
KhbsCbRwTIfNJ3vc5Gl/curdOcuEOJPsh143yZkaVOtalwHKpGg1OSSExZxnoKRq
ZF5ZWeIGtJUCQ0F18fs/Dg74j/dauwAn7VlyDj9HNDQoW/2SDDh3DAwzaHXLaNSi
gBHyjoaq6zNVilUTS86mSdwSMb4lwPWNVkmCgdZpf4UkEDUfO3k0o/Yky8U+cVQB
q+n77r4WHAvUNVX8tEWGZmMs3rd/KgP5k/3iCAYQsvNu74EB62VAiZQ7HDUEoveT
lufLNYVLClt/HZfIYI4BH23UoJGmBxHyUdGWnsGwEB8t6Q830bX+1EjprXJivrV6
cxNMWaLuus1BKVPuv6vng8sxE/r4XpUB7tsBcBtQr8CF/1eM7k3y21puXYGMjLNq
z7dNTjsgO6OrdbHh8M7HXokMDAco6lS12/2ye3cP4n5SeTR8hD6VI2lCc7jLl2UY
RCq0y9OwzHN6kWlKfjL0VTmpMFbRiLqfGxSqm24qavClAEVRneIhM+KdTcCa0G3S
gZGl5splwm/xbIwKa6Jgyb3W+WdxScdRyKuR5GDYwHr1uLXdOwOEn1P9cEPXR6H4
NrH4KeeDgpy1nIdAZbQT
=7GjX
-----END PGP SIGNATURE-----

--=-ViVrOBgV0i4J1JeyUTym--
