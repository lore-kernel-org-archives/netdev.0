From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH] rtl_bt: Add firmware and config file for RTL8822BE
Date: Tue, 30 Aug 2016 15:51:38 +0100
Message-ID: <1472568698.25374.9.camel@decadent.org.uk>
References: <1472566081-1072-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-BIi4uSpmmt1zprnli1nK"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        =?UTF-8?Q?=E9=99=86=E6=9C=B1=E4=BC=9F?= <alex_lu-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>, linux-firmware-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472566081-1072-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-BIi4uSpmmt1zprnli1nK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-08-30 at 09:08 -0500, Larry Finger wrote:
> This device is a new model from Realtek. Updates to driver btrtl will
> soon be submitted to the kernel.
>=20
> These files were provided by the Realtek developer.
>=20
> Signed-off-by: =E9=99=86=E6=9C=B1=E4=BC=9F <alex_lu-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
> =C2=A0WHENCE=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=
=C2=A0=C2=A03 +++
> =C2=A0rtl_bt/rtl8822b_config.bin | Bin 0 -> 32 bytes
> =C2=A0rtl_bt/rtl8822b_fw.bin=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| Bin 0 -> 5175=
6 bytes
> =C2=A03 files changed, 3 insertions(+)
> =C2=A0create mode 100644 rtl_bt/rtl8822b_config.bin
> =C2=A0create mode 100644 rtl_bt/rtl8822b_fw.bin
>=20
> diff --git a/WHENCE b/WHENCE
> index d0bef0d..a9d7c97 100644
> --- a/WHENCE
> +++ b/WHENCE
> @@ -2755,11 +2755,14 @@ File: rtl_bt/rtl8723b_fw.bin
> =C2=A0File: rtl_bt/rtl8761a_fw.bin
> =C2=A0File: rtl_bt/rtl8812ae_fw.bin
> =C2=A0File: rtl_bt/rtl8821a_fw.bin
> +File: rtl_bt/rtl8822e_fw.bin
> +File: rtl_bt/rtl8822e_config.bin
[...]

Should the filenames begin with "rtl822b" or "rtl822e"?

Ben.

--=20
Ben Hutchings
All the simple programs have been written, and all the good names
taken.

--=-BIi4uSpmmt1zprnli1nK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJXxZ17AAoJEOe/yOyVhhEJ8H4P+wSbYmV/m1C6pLHGzahc9v5X
a2y3C2eVRmzWUMM4aQcI1V/25kqG4UI6t9BLSMki7vhyYfy3Fsov4uX7aatBoDTH
o95HlbolaPOK9+OcIzLA3F4cv6u7xdse8nxzTdn01PK6gOmtEgeYleur2FfvDrFH
XNUxudOqbbQ0INlh9KPen5n36zSr0XO9VpN/bYBpEb2N7DqK3RVbkUOJIxgE8b/c
fn2VQIREIPKU3zDjScSrMtgdOQmHsaNym6nDhrO9iy3llQ3PTrzd5ocX+iZkBAkC
CHmYekMeA3xkrQvW9P61p5r03gsm3/I/Rt31Hoe1RPieUen3Essm4HfUTAJgocwG
DPBBNBLu0bArI5lnQnOyb8HPWMh1fVmtwaKEzxIgkKGrQ52EYVcNu9MrIcMM6AED
VFqgNyZR8yJiiFdzrxutKb7qu0BaDLk6VWgu1knKDj5E49npuwuX9IU9xrjWhUhf
s8LGD29qQ6O/mEtYj9LbXbw5eeLbmn5hWrZANZHnXmyTufbSV7+ozWdFfcxJNSVZ
P28fMe3aiZPw8KZ0aH0Ucomg2oUcVYg8exEaLb8b1wuWKBzF8CZuZ7gQMI/tuNVN
4Hw9nvO5akj9T8JkXHxySSWP4zo9OwlG4W2jMp4GwqHRu1W9MN4J9r3y1UxiodwA
beh99KiYVvOqKyRmlprV
=dGP7
-----END PGP SIGNATURE-----

--=-BIi4uSpmmt1zprnli1nK--
