From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] driver/e1000e: Fix default interrupt mode select
Date: Tue, 12 Apr 2011 14:31:25 -0700
Message-ID: <1302643885.2950.12.camel@jtkirshe-MOBL1>
References: <1302584163-22318-1-git-send-email-prabhakar@freescale.com>
	 <20110412.142727.39177723.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-6d1wuZR3mHt4W/8Ap8yD"
Cc: "prabhakar@freescale.com" <prabhakar@freescale.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	Linux NICS <linuxnics@mailbox.intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"meet2prabhu@gmail.com" <meet2prabhu@gmail.com>,
	"b24347@freescale.com" <b24347@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42213 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932568Ab1DLVb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 17:31:26 -0400
In-Reply-To: <20110412.142727.39177723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6d1wuZR3mHt4W/8Ap8yD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-04-12 at 14:27 -0700, David Miller wrote:
> From: Prabhakar Kushwaha <prabhakar@freescale.com>
> Date: Tue, 12 Apr 2011 10:26:03 +0530
>=20
> > From: Prabhakar <prabhakar@freescale.com>
> >=20
> > The Intel e1000 device driver defaults to MSI interrupt mode, even if M=
SI
> > support is not enabled
> >=20
> > Signed-off-by: Jin Qing <b24347@freescale.com>
> > Signed-off-by: Prabhakar Kushwaha <prabhakar@freescale.com>
> > ---
> >  Based upon git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linu=
x-2.6.git(branch master)
> >=20
> >  added  netdev mail-list and e1000 mail-list & maintainer
>=20
> Intel folks, you got this?

Yes.  Thanks Dave.

--=-6d1wuZR3mHt4W/8Ap8yD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNpMStAAoJECTsCADr/EWUessH/2an3cy2mCNzDuZtKDBIBJFR
MCy++2gWcYAv/83GteLFtBnHXcmi20y1MxtWjIEf0CuDpH1kvfN/UgOxmlb7J+dj
5JbfGKdFDE1ys2ClDnbff7HXbBI6WrjTWD08hCNTCLugfu8ZQRhSRXnGEnJOjStJ
0+LFdnqOECI/k1myYfLeTKAbguGMO0pCwfQXBpC0FvyGriaCPLXolkhqC7RqXYsp
S73xJQceSjk6GY5NQKFqzauIhgJipERyJw9gNRlMbXKE+eDi4K2PY6h1PEetAttz
Z+7V/0udic8meDCcgrLjGGGj/8iwZyMBbEGLHvL6hR67D+fjaokepIj+w0NsBZQ=
=us20
-----END PGP SIGNATURE-----

--=-6d1wuZR3mHt4W/8Ap8yD--

