From: Florian Lohoff <flo@rfc822.org>
Subject: Re: 2.6.23-rc1 sky2 boot crash in sky2_mac_intr
Date: Wed, 25 Jul 2007 09:22:02 +0200
Message-ID: <20070725072202.GA4905@paradigm.rfc822.org>
References: <20070724082205.GA19480@paradigm.rfc822.org> <20070724095008.0eb154fe@oldman.hamilton.local> <20070724094042.GA6414@paradigm.rfc822.org> <6bffcb0e0707241630p3599ad99sfd778097b307e78c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mP3DRpeJDSE+ciuQ"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.gt.owl.de ([195.71.99.218]:53923 "EHLO hydra.gt.owl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752799AbXGYHWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 03:22:03 -0400
Content-Disposition: inline
In-Reply-To: <6bffcb0e0707241630p3599ad99sfd778097b307e78c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 25, 2007 at 01:30:31AM +0200, Michal Piotrowski wrote:
> >I'll try the above and keep you posted. The crash itself seems to be a
> >2.6.23-rc1 regression though. I never experienced this with 2.6.22-rc5
> >which i was running before.
>=20
> Can you try to figure out what is causing this crash and then use=20
> git-bisect?

Are there so many changes between 2.6.22-rc5 and 2.6.23-rc1 for the sky2?

As the crash is not that reproducible, just occasionally on boot i guess
bisecting is more or less waste of time.

Flo
--=20
Florian Lohoff                  flo@rfc822.org             +49-171-2280134
	Those who would give up a little freedom to get a little=20
          security shall soon have neither - Benjamin Franklin

--mP3DRpeJDSE+ciuQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGpvoaUaz2rXW+gJcRAkKvAJ42pgvV9+D6A5IGdkfmGtCh+/oaAgCgrhSu
TeO5shqNXhla0nn9aXaNLvQ=
=1qvr
-----END PGP SIGNATURE-----

--mP3DRpeJDSE+ciuQ--
