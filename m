From: Mark Brown <broonie@kernel.org>
Subject: Re: ipv6: fix headroom calculation in udp6_ufo_fragment
Date: Fri, 13 Dec 2013 13:42:05 +0000
Message-ID: <20131213134205.GB11044@sirena.org.uk>
References: <D00A5DFD97C44C4D820FC3A847C5D5750730630F@IRVEXCHMB14.corp.ad.broadcom.com>
 <20131213133453.GB7332@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="41bjdpi19TcwJlr2"
To: Mark Hambleton <mark.hambleton@broadcom.com>,
	'Pravin B Shelar' <pshelar@nicira.com>,
	'Saran Neti' <Saran.Neti@telus.com>,
	"'David S. Miller'" <davem@davemloft.net>,
	'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'stable@vger.kernel.org'" <stable@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131213133453.GB7332@order.stressinduktion.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--41bjdpi19TcwJlr2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Dec 13, 2013 at 02:34:53PM +0100, Hannes Frederic Sowa wrote:

> Sorry, I don't know which version the LTS kernel is. Upstream does not use
> sk_buff_data_t for mac_header any more.

This is with v3.10.

--41bjdpi19TcwJlr2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSqw6qAAoJELSic+t+oim9HLgQAIQSOaRtx3Lv4UxsuZzLMf0T
TIn51Jam9Xr1O6ztSwXclPXxhi02diwK+RPhYuJnUiOxSPURazrqO+h48O2r36D0
dS9UTqLw3x5wZzRAbAKK1yJR1ODjR2vYnERQ4s/vKAcSwWTXRR/bciGV3l4xYN3e
vDf12Jif8bjftgc4fulTK/QDg2puOCFAtX4Jc1aus7wqpq2W0KhO6j/VoU1g39iF
y+mzUY4SJTl2GkNAkQz2HHtB0ToouppNH13hzeh4xA+RFgWzQKnuyayi48QO61aa
9k2OGlA42sKaicdEjdFVbFDTOoIF65tYNbGuvoK3pyx/Zq29BJf/+5mFiPuLjWO+
8e5dleuMR8Mkb0VhVfIIhsX57WNE/4A5PklgO7onHOMeI5OgSejEB3u2Z5JQWaj5
e+y3f6paoKNVxFU6mztSJc8LA+5JEZryrcy+0fcKj/zrcdRyG6xDF7VQp3AE5qEr
rKrx1SX0UpHuUACHz1XH+kQyqBvwy6M0oXEk0NyAeD+82M4uP2A4XRtHNO8jBXao
YJHOo/W9Vc3Dp/MbpcZv4TjDp9pPlHFZUOmkr/pyxSI6g2aM1ff5Zzav4WJhwvye
1DaPskk4L6GKIBzfzealfrR0wpYcrlF+ILFbFVsorzqRJndn5ibF4ovbM/FVj7vW
6GPCtkjjrpMYNqavDZ17
=+ZL8
-----END PGP SIGNATURE-----

--41bjdpi19TcwJlr2--
