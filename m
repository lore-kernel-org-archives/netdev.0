From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 1/2] can: rcar_can: Add r8a7795 support
Date: Mon, 29 Feb 2016 10:38:45 +0100
Message-ID: <56D411A5.9070706@pengutronix.de>
References: <1456737661-20538-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1456737661-20538-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Qsc6qjR6hkmMe0dFLmbkfq7NGW9UKqASk"
Cc: linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.paterson2-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org, magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1456737661-20538-2-git-send-email-ramesh.shanmugasundaram-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Qsc6qjR6hkmMe0dFLmbkfq7NGW9UKqASk
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/29/2016 10:21 AM, Ramesh Shanmugasundaram wrote:
> Added r8a7795 SoC support.
>=20
> For smoother bit timing calculation, the rounded clock frequency is use=
d.

Why this? From my point of view this introduces a clock error.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Qsc6qjR6hkmMe0dFLmbkfq7NGW9UKqASk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW1BGlAAoJED07qiWsqSVqj9wIALV0Be3Dw2xV2MBDLliLjsEV
5d5vkR56on1+IqlyQsfIGgaffCoKOncnaZK0tlnR3r9RF9DmQUOlXEOkB9+VN9ss
SmmtpBsn2e6tRrmeYgWyllY+pv6qOiHWLuXWpfVXBnpNt+Pq7hrh7LbUO3U1Ypka
xZQ44xcq9HQgW8lcXIloOt+wSMl18ufL3h7ljnML8vEWKYJHKgEGgM+I3wrU3kMZ
G55PBXRafmHBv++8QjLEXF1cBTio2E7odkvoT9NdtkY86mi+8VNDu2I0cR7ompiJ
75/kfbcYF9RSu/irw29b5HHro7OleTdwfOcJ4uvL46FcDHi0xgg64JZALVFhVog=
=ookP
-----END PGP SIGNATURE-----

--Qsc6qjR6hkmMe0dFLmbkfq7NGW9UKqASk--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
