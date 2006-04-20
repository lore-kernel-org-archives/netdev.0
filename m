From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull upstream-fixes branch of wireless-2.6
Date: Thu, 20 Apr 2006 11:12:56 +0200
Message-ID: <200604201112.56666.mb@bu3sch.de>
References: <20060420011232.GA9268@tuxdriver.com> <200604201051.03881.mb@bu3sch.de> <20060420015752.01d36087.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1333362.nNArlSiFBB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jeff@garzik.org, netdev@vger.kernel.org,
	torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49603
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750712AbWDTJIs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 05:08:48 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060420015752.01d36087.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1333362.nNArlSiFBB
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 20 April 2006 10:57, you wrote:
> Michael Buesch <mb@bu3sch.de> wrote:
> >
> > On Thursday 20 April 2006 03:12, John W. Linville wrote:
> > >       bcm43xx: fix dyn tssi2dbm memleak
> > >       bcm43xx: fix pctl slowclock limit calculation
> > >       bcm43xx: sysfs code cleanup
> >=20
> > These are already in -mm and on their way into linus's tree.
>=20
> I don't send netdev patches to Linus except under unusual circumstances.=
=20
> I'd expect these patches to go upstream via John or Jeff.
>=20
> > Is it possible to cause problems?
>=20
> Nope, I'll just drop then when they appear in a git tree.
>=20
> And I really need to find a way of getting git-wireless into -mm.  Problem
> is, it's based off git-netdev-all and when John's tree is synced to a lat=
er
> version of Linus's tree than Jeff's tree, all hell breaks loose at my end=
=2E=20
> Junio and I weren't able to work out a way of extracting the jeff->john
> diffs so I gave up.
>=20
> Probably, I'll need to actually do a git merge, generate the diff then
> throw away the resulting git tree.  Or something.  I've avoided doing git
> merges because I'm dealing with 58 trees and I suspect I'd go insane.
>=20
> > If not, fine. If yes, we need some clearly defined rules where
> > to put patches and a clearly defined statement of how often
> > patches are pushed upstream.
>=20
> Because I don't carry git-wireless I don't have visibility of when John h=
as
> merged something.  Ordinarily you'd have seen me drop the patches again
> when they popped up in John's tree.

Ok, that is perfectly fine and it will work.
Thanks for the clarification.

=2D-=20
Greetings Michael.

--nextPart1333362.nNArlSiFBB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBER1CYlb09HEdWDKgRAlH6AJ45ftaGS+p24oBgep8SWBfNYel2ugCfb2ir
CBOdNlgksP3pCKvgfVyZfRA=
=UZ0h
-----END PGP SIGNATURE-----

--nextPart1333362.nNArlSiFBB--
