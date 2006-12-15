From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] p54: Fix compilation for d80211 hwmode API change
Date: Fri, 15 Dec 2006 16:38:19 -0500
Message-ID: <200612151638.24454.flamingice@sourmilk.net>
References: <200612152045.36135.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3172347.asLMutLC4W";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, John Linville <linville@tuxdriver.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:46316 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753466AbWLOVio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 16:38:44 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200612152045.36135.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3172347.asLMutLC4W
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 15 December 2006 14:45, Michael Buesch wrote:
> This fixes compilation for the d80211 hwmode API change.
>
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
>
We can't specify modes before device registration now? There would be less=
=20
duplicated code here if we could.

=2DMichael Wu

--nextPart3172347.asLMutLC4W
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFgxXQT3Oqt9AH4aERApJuAKDBfvAexsxdPqMfpt4FtRC0E0v36gCgmCty
XT9MMmmTdzBHreMM/O3j1h0=
=5I6r
-----END PGP SIGNATURE-----

--nextPart3172347.asLMutLC4W--
