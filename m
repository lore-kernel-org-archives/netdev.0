From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V6 1/3] bfin_can: rewrite the blackfin style of read/write
 to common ones
Date: Fri, 06 Feb 2015 08:53:23 +0100
Message-ID: <54D472F3.8010508@pengutronix.de>
References: <1423203952-23004-1-git-send-email-Aaron.wu@analog.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="MLniLINRrAUEa4Bj4HxGqliTMfTd25gF9"
To: Aaron Wu <Aaron.wu@analog.com>, wg@grandegger.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-devel@analog.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1423203952-23004-1-git-send-email-Aaron.wu@analog.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MLniLINRrAUEa4Bj4HxGqliTMfTd25gF9
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/06/2015 07:25 AM, Aaron Wu wrote:
> Replace the blackfin arch dependent style of bfin_read/bfin_write with
> common readw/writew

Patch 1 & 2 are fine, 3 needs some whitespace improvements (see my reply
for more details).

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--MLniLINRrAUEa4Bj4HxGqliTMfTd25gF9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU1HL6AAoJECte4hHFiupUywMP/iWMKxDki0cH23i3oIbp1pMm
b9UBDuf5HrIJqWM9J39pH+nQtn3Z4Vi3w3GiI5p/y5lOEIsNaM4DLgRER3F+g+VS
kfir6QcOhFg3UwMEUlziTpaUTmqulcgjXlcaV7D5zSkZmNrryFMnYtE/e38XS+K8
nYo4m+6OeXnuc78uFhsQJ2vlBOwDtCF+zkIo85FtM/pm3CC8+lny2xwI+Mh56Q76
4SwReOQ6MosdRq9rZBKxEdCycPEhyQYLuz9HU3BijjGkG0MnE24jFehLw8q+POPW
649xRVUaqZOWv1+JIbsb+ODbECypJ51nI7SoaBUYBB9MdfnumiRUFEAl7v33gzHJ
OIQ016npYXndvGnBTYtMukJazz2CjEPnukYYhMACVQobweRAw9RVDjTSq1nWtad2
S9hyQvu3ywqBq6pkOndjktUFAJ2FUHYNnGTs31fFoioekzsB5h4XeBdF5Ri89/oh
DahA9ynSkOMh/ADy5YqEdyatzhCwBREKFpjd38lKYBKxGm7fGgJ1U3OfHbg+yCfE
xRWCnqMUKev+FRqOvD9vNAJ/11KWTLVgcofAInp/62XA0ShBBc2PwC7f6NTuKKUn
EldCnYOi0SaAFgVHA0wnYJR11nlD4ixnlqIWO/Yt+6VQIqKwAj/9Tq84WbXgcMcE
6g0AEnmUvx8VXT9k667P
=mEJe
-----END PGP SIGNATURE-----

--MLniLINRrAUEa4Bj4HxGqliTMfTd25gF9--
