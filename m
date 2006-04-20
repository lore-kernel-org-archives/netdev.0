From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull upstream-fixes branch of wireless-2.6
Date: Thu, 20 Apr 2006 10:51:03 +0200
Message-ID: <200604201051.03881.mb@bu3sch.de>
References: <20060420011232.GA9268@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1423931.dKqH8lOSqi";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@osdl.org,
	torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:34745
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750716AbWDTIrW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 04:47:22 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060420011232.GA9268@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1423931.dKqH8lOSqi
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 20 April 2006 03:12, John W. Linville wrote:
>       bcm43xx: fix dyn tssi2dbm memleak
>       bcm43xx: fix pctl slowclock limit calculation
>       bcm43xx: sysfs code cleanup

These are already in -mm and on their way into linus's tree.
Is it possible to cause problems?
If not, fine. If yes, we need some clearly defined rules where
to put patches and a clearly defined statement of how often
patches are pushed upstream.

=2D-=20
Greetings Michael.

--nextPart1423931.dKqH8lOSqi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBER0t3lb09HEdWDKgRAoPPAJ4i5xvIHhnwdDqLxAN3WJxxFw5iDgCbBjEd
W1CN8ropucjhr9omGYCQMN0=
=ch/K
-----END PGP SIGNATURE-----

--nextPart1423931.dKqH8lOSqi--
