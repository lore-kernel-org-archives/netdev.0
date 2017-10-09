From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v1 RFC 5/7] Break KSZ9477 DSA driver into two files
Date: Mon, 9 Oct 2017 21:54:38 +0200
Message-ID: <20171009195438.GE9866@amd>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-6-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Uwl7UQhJk99r8jnw"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>,
        muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507321985-15097-6-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Uwl7UQhJk99r8jnw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2017-10-06 13:33:03, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
>=20
> Break KSZ9477 DSA driver into two files in preparation to add more KSZ
> switch drivers.
> Add common functions in ksz_common.h so that other KSZ switch drivers
> can access code in ksz_common.c.
> Add ksz_spi.h for common functions used by KSZ switch SPI drivers.
>=20
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>

Reviewed-by: Pavel Machek <pavel@ucw.cz>

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--Uwl7UQhJk99r8jnw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnb0/4ACgkQMOfwapXb+vKXpACeNBp8bmxOxlFlALFSOiEJbWIr
RAcAoLRJtpBPfMsrSpMlIwaREnkkk+3W
=S6U6
-----END PGP SIGNATURE-----

--Uwl7UQhJk99r8jnw--
