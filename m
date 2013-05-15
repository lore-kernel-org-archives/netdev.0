From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 07/11] net/peak_pcmcia: take msecs_to_jiffies_min into
 use
Date: Wed, 15 May 2013 11:12:44 +0200
Message-ID: <5193518C.3040706@pengutronix.de>
References: <1368188011-23661-1-git-send-email-imre.deak@intel.com> <1368188011-23661-7-git-send-email-imre.deak@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2PNOBNGTSUMEMBABXASGK"
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joe Perches <joe@perches.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Imre Deak <imre.deak@intel.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1368188011-23661-7-git-send-email-imre.deak@intel.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2PNOBNGTSUMEMBABXASGK
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 05/10/2013 02:13 PM, Imre Deak wrote:
> Use msecs_to_jiffies_min instead of open-coding the same.
>=20
> Signed-off-by: Imre Deak <imre.deak@intel.com>

Tnx, applied to linux-can-next/master.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2PNOBNGTSUMEMBABXASGK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGTUYwACgkQjTAFq1RaXHP48QCdEMb8xFkbN/xEMwk6+nl0WdqZ
/N8An1ecBfxBpaF3pDbNt1kOejjLMFDI
=Vlfc
-----END PGP SIGNATURE-----

------enig2PNOBNGTSUMEMBABXASGK--
