From: Pavel Machek <pavel@denx.de>
Subject: DSA support for Micrel KSZ8895
Date: Wed, 16 Aug 2017 09:55:24 +0200
Message-ID: <20170816075524.GA18532@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Tristram.Ha@micrel.com,
        Woojung.Huh@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I've got hardware with KSZ8895, and I'd like to use switch ports as
separate ethernet cards. I believe that means DSA support.

And there are even patches available from microchip... unfortunately
they are in strange form and for v3.18.

http://www.microchip.com/SWLibraryWeb/product.aspx?product=3DKSZ8895%20Soft=
ware%20Linux%203.18

Is there newer version of the driver available somewhere? Is the
driver good starting point, or should I start with something else?

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmT+msACgkQMOfwapXb+vIxbgCffNbfJxFutoOQXD84q0UPMehq
28wAnjqT6jYI6R0UzRAeM45TIqkBUvTx
=qRpr
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--
