From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] cc770: linux/can/dev.h included twice
Date: Wed, 15 Feb 2012 20:37:47 +0100
Message-ID: <4F3C098B.4050308@pengutronix.de>
References: <1329328501-4737-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig66A4AFC2ED99B78C6F209036"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329328501-4737-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig66A4AFC2ED99B78C6F209036
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/15/2012 06:55 PM, Danny Kukawka wrote:
> drivers/net/can/cc770/cc770.c included 'linux/can/dev.h' twice,
> remove the duplicate.
>=20
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Thanks, applied to can-next.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig66A4AFC2ED99B78C6F209036
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk88CY4ACgkQjTAFq1RaXHMYQACgjRVbyF5L1w3ZJ5DRBDhCYedb
A34AnRTM/RxyM9R99EfxxiCq9aBREh7r
=Dof9
-----END PGP SIGNATURE-----

--------------enig66A4AFC2ED99B78C6F209036--
