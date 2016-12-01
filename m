From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] can: rcar_canfd: Correct order of interrupt specifiers
Date: Thu, 1 Dec 2016 14:24:33 +0100
Message-ID: <81027038-8cf6-716b-c0a8-dc2343b93d70@pengutronix.de>
References: <1479908686-14028-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="ILdBRDmh1GxT8KQ9N1ABKJ2M7ANNK1dVn"
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>,
        Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
        Ramesh Shanmugasundaram <ramesh.shanmugasundaram-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>,
        Chris Paterson <chris.paterson2-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479908686-14028-1-git-send-email-geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ILdBRDmh1GxT8KQ9N1ABKJ2M7ANNK1dVn
Content-Type: multipart/mixed; boundary="jIfpoabaDQFDq77gFrl9p8TCsUqDHRbVP";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>,
 Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
 Ramesh Shanmugasundaram <ramesh.shanmugasundaram-kTT6dE0pTRh9uiUsa/gSgQ@public.gmane.org>,
 Chris Paterson <chris.paterson2-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org>
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <81027038-8cf6-716b-c0a8-dc2343b93d70-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] can: rcar_canfd: Correct order of interrupt specifiers
References: <1479908686-14028-1-git-send-email-geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <1479908686-14028-1-git-send-email-geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>

--jIfpoabaDQFDq77gFrl9p8TCsUqDHRbVP
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/23/2016 02:44 PM, Geert Uytterhoeven wrote:
> According to both DTS (example and actual files), and Linux driver code=
,
> the first interrupt specifier should be the Channel interrupt, while th=
e
> second interrupt specifier should be the Global interrupt.
>=20
> Signed-off-by: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>

Added to can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--jIfpoabaDQFDq77gFrl9p8TCsUqDHRbVP--

--ILdBRDmh1GxT8KQ9N1ABKJ2M7ANNK1dVn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlhAJJEACgkQPTuqJayp
JWrYhAf8DV4nJQ7xTYC23sjccBNoEXGkESvlq6ZQw4/CT2bvPKFGniwL2ezkY1TK
cwnK6IKavZtN0IgZS61e5ktX+ORniSP9Hq1h1swlnqlNb5BgmQc059v/rNPkzCdh
YClEScIHtVoC399/cAa1xX51GGAlt7sm5Z4UoRBj7/iruBzYFKIjGZ2OfMXmhoTE
kFS+uGfsPseqIwaQ1+fPyflAcYm+ahJlhh4c5Gpni5HLcSM5ZmLtXEQskmvuEi2D
rRQs5vMUOrZLHv74gcqOAYhsBrGvv+6P56rmW1ui9wbDeO4GqQ04Vi78VjilD6ov
svniJeMlNCQWoLYPl67fbgBexpOftQ==
=iPGA
-----END PGP SIGNATURE-----

--ILdBRDmh1GxT8KQ9N1ABKJ2M7ANNK1dVn--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
