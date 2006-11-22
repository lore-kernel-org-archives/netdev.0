From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] adm8211: Use ieee80211_generic_get_stats
Date: Tue, 21 Nov 2006 22:21:39 -0500
Message-ID: <200611212221.44171.flamingice@sourmilk.net>
References: <20061122031613.52BA77B40A0@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6892255.MR7NphWm0m";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:60268 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP id S967020AbWKVDW7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 22:22:59 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20061122031613.52BA77B40A0@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6892255.MR7NphWm0m
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 21 November 2006 22:16, Daniel Drake wrote:
> I am sending the adm8211 patch separately because adm8211 is
> not in Linus' tree.
>
And it won't be, because the only reason adm8211 went into wireless-2.6 is=
=20
because someone requested it. Only the d80211 version of adm8211 is=20
supported, and I think the wireless-2.6 version crashes. Please ignore=20
adm8211 in wireless-2.6.

=2DMichael Wu

--nextPart6892255.MR7NphWm0m
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFY8JIT3Oqt9AH4aERAkleAJ4lI/ysq3etHRsmrXctBubYvx7Z+wCdG3Tj
nnCKUMD6KOqCoJ0+SDMvuL0=
=IRbx
-----END PGP SIGNATURE-----

--nextPart6892255.MR7NphWm0m--
