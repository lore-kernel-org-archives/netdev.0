From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 0/17] d80211 patches
Date: Thu, 27 Apr 2006 14:49:51 +0200
Message-ID: <200604271449.51741.mb@bu3sch.de>
References: <20060421220951.205579000.midnight@suse.cz> <20060421225210.36a0225b@griffin.suse.cz> <20060426193907.GB7922@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5514745.pGZKWGAVoE";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:42201
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965123AbWD0Moa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 08:44:30 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060426193907.GB7922@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5514745.pGZKWGAVoE
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 26 April 2006 21:39, John W. Linville wrote:
> On Fri, Apr 21, 2006 at 10:52:10PM +0200, Jiri Benc wrote:
> > On Fri, 21 Apr 2006 22:52:08 +0200, Michael Buesch wrote:
> > > Can you please send your hacky patch for the bcm43xx
> > > to me, so I can come up with a clean one?
> >=20
> > Sure, actually I planned to do it in a few minutes :-)
>=20
> Hacky or not, I'm applying this patch to keep the bcm43xx driver
> from breaking.
That's perfectly fine.
The correct patch needs a little bit of rewriting in the "mode" code.
I will do that after I finished the 4318 fixes (should take quite
some time).

=2D-=20
Greetings Michael.

--nextPart5514745.pGZKWGAVoE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEUL3vlb09HEdWDKgRAnNxAJ9I5T3uw8i6GXdRKY/iKETtaY5WqQCdHtqL
Sa0pB4hkp2NyXychmHKY0ZI=
=6NBN
-----END PGP SIGNATURE-----

--nextPart5514745.pGZKWGAVoE--
