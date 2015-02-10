From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V8 1/3] bfin_can: rewrite the blackfin style of read/write
 to common ones
Date: Tue, 10 Feb 2015 11:05:24 +0100
Message-ID: <54D9D7E4.2010203@pengutronix.de>
References: <1423561237-11043-1-git-send-email-Aaron.wu@analog.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="nqqSe7kbnP6p3TE6Cgxqn7uRu43XLU80N"
To: Aaron Wu <Aaron.wu@analog.com>, wg@grandegger.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1423561237-11043-1-git-send-email-Aaron.wu@analog.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--nqqSe7kbnP6p3TE6Cgxqn7uRu43XLU80N
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/10/2015 10:40 AM, Aaron Wu wrote:
> Replace the blackfin arch dependent style of bfin_read/bfin_write with
> common readw/writew

Applied to can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--nqqSe7kbnP6p3TE6Cgxqn7uRu43XLU80N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU2dfqAAoJECte4hHFiupUsGAP/RQPL1sOcSKuZ5/B8UhG51uJ
S8EJmYOutxQgxQlHdepk/0MwR8C+M1RWwN0FeJJnx3Y7Cfr3GSaTGU4MwxHnEMpO
xsaXcv2yc8uBSlb4fVqy+u5CwIXAsbjnTaXOZhS9Z+gcicXCG+nDLzZEpB8UCIM5
5scuALaI1MIB+Xy84knEANbuKJ3kH9475cuBpnxlTduP7Eql5nvAFBF7RqFu5WNh
3mtOZtvjodXicdqt6QFQOdLnYcNiYhg/FFgiuULDEXuj/tjFArtgED+NvvAWzKWv
H+cmnI9BpM9hou7d3TLZclF7B6Z4+pmMz3/mahL355Zcp1MzrMQRxDTOnmqOOtgd
zgqjdUa/fYIM5r0d9bhvEiGWyfnRhvB2oc/VdOKokadXe0xmZAP75B7YTJxohELB
glFa7VJjoiGX1tGNkP+qVhyfvtrR7oti9wVdTwtGT7+kYy47CN4pkH/CAc8Als55
uYWM+S1yQfdOVs1J0eB4M0Qq6XqxqZ3kgZ5THp3RvpY+GlUer6aKh3YgYt6/e2T0
Wdmv6u5tj3WYnCNhfnrGgHOuU29GPuJpWxoauLgpCkrOhEfYntBIA5yIZrI5NoC/
jJ3kBtixiKXj3JM8jPz0/jcEnFKuFiIk3vYVnp1oOh9LXWRsdNNLkKBa1dp/mZpT
FpjmLTsQ0CiRWWmk7uxj
=1SSL
-----END PGP SIGNATURE-----

--nqqSe7kbnP6p3TE6Cgxqn7uRu43XLU80N--
