From: Petr =?utf-8?Q?=C5=A0abata?= <contyk@redhat.com>
Subject: Re: [RFC] iproute2: split up ip man page?
Date: Thu, 8 Dec 2011 10:15:02 +0100
Message-ID: <20111208091502.GA537@rincewind.brq.redhat.com>
References: <20111207131514.6815f813@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="6TrnltStXW4iwmi0"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16524 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab1LHJRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 04:17:41 -0500
Content-Disposition: inline
In-Reply-To: <20111207131514.6815f813@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07, 2011 at 01:15:14PM -0800, Stephen Hemminger wrote:
> The current ip man page is both incomplete and so big that
> the actual functions get lost easily.

I totally agree.

> I propose splitting the the pages for the subfunction
> into sub pages. The man command appears
> to be smart enough to handle:
>   man tc htb
>=20
> and pickup the manpage for /usr/share/man/man1/tc-htb.8.gz
> Why not do the same thing for ip command?
>=20
> The base ip page would just be a place holder that covered the
> generic arguments.

+1

-- Petr

--6TrnltStXW4iwmi0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iF4EAREIAAYFAk7ggBYACgkQT+hZYwG3Kb4XIgEAj0Lwx4oDiuIH3gqolnP02Vwm
68IodPG0lLONgATB8BMBANXA7ku2fjPZtHBGHhQFEGWhF8fWbpwuBcJAOYkx/XN/
=Gpg9
-----END PGP SIGNATURE-----

--6TrnltStXW4iwmi0--
