From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 02/10] 3c*/acenic/typhoon: Move 3Com Ethernet drivers
Date: Thu, 11 Aug 2011 03:07:50 -0700
Message-ID: <1313057272.2339.5.camel@jtkirshe-mobl>
References: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1313033278-7337-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110811100255.421a5fbc@bob.linux.org.uk>
	 <1313054026.2339.3.camel@jtkirshe-mobl>
	 <20110811105839.12694227@bob.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-+ZXTkIZKlAMSwe8U3d/G"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@tredhat.com" <gospo@tredhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	David Hinds <dahinds@users.sourceforge.net>
To: Alan Cox <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15308 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754492Ab1HKKHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 06:07:54 -0400
In-Reply-To: <20110811105839.12694227@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+ZXTkIZKlAMSwe8U3d/G
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-08-11 at 02:58 -0700, Alan Cox wrote:
> > Where would you like to put it? drivers/net/ethernet/alteon/?  I am
> > fine with fixing this up by placing somewhere else.
>=20
> If you are going by chip vendor then I guess yes it goes into alteon.
>=20

Ok, I will create a patch to fix this up.  This patch will be in the
last series of patches I send.

--=-+ZXTkIZKlAMSwe8U3d/G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOQ6n2AAoJECTsCADr/EWUvaAH/3Fk9sZxI26zgiYwcn450fuX
W8WjKHCS8I83VbbVzJouv+XaD3iFZExi1kvvlyAdnbcc2zMPxVVJuv0Nd29bsJUO
cgNys3oAVGrF/Up9PuRUbTk9ZFWDgjHVhXEu82TjICbPa7mzrCVxdtCfPx9Htm4J
GpgQydyxMkFraHZl1x1W9vVYtYHS4TXInEQtDuJGf9+fH5GQAbmoV94/roC5s8js
Ybu8AuzEFwOIvg/tGUkJhUzI9kw5+fot8HoLXla4ghWzDp/E0WCNHWMrQBR1C7Xt
sOtoGKq9bHbH3ki+2s4r9qrGSUi36aQPmWfdn/ub8x7Lr3X9ku6fKa6RbhS0LBo=
=BUdT
-----END PGP SIGNATURE-----

--=-+ZXTkIZKlAMSwe8U3d/G--

