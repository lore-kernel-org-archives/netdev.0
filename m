From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH v2 net] ipv6: addrconf: fix Juniper SSL VPN client regression
Date: Mon, 11 Jul 2016 12:02:43 -0400
Message-ID: <6093.1468252963@turing-police.cc.vt.edu>
References: <1468248230-5763-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1468252963_5025P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jonas Lippuner <jonas@lippuner.ca>,
	=?iso-8859-1?Q?=5409=85E4=82F1=660E?=
	<hideaki.yoshifuji@miraclelinux.com>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.smtp.vt.edu ([198.82.183.121]:54120 "EHLO
	omr2.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755085AbcGKQC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 12:02:56 -0400
In-Reply-To: <1468248230-5763-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1468252963_5025P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, 11 Jul 2016 16:43:50 +0200, Bj=F8rn Mork said:

> And finally, Valdis and Jonas: could you please test this version too? =
It
> works for me in my simulated setup, but I don't have the Juniper client=

> so I cannot verify that it actually solves the problem.

The v1 patch worked.  I'll be able to test the v2 patch in a few hours...=
.

--==_Exmh_1468252963_5025P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBV4PDIwdmEQWDXROgAQLHvg//fxZUDDoy1T0cpcyobG0cWxbTCg+4Enw/
npPdOVi8dbwSR4uYZxfIlNcyyJtNes0WHpyZrq7xcvY5j3xU/CQ/UpH5mCUnyrjw
HoDtEtmj9/dEJ0xkQ+Qcbop6gaS1e5cdLtOlDZpYc3ZwxN1edhxpWQC8vnrjkL2Q
lAQG45NTsmzz4Q0lJs9mzqmTcH46XQhJQTFzkshbo1y/K/x4JyiNp1I9X6pmPb3D
OQMWDvk+WdPRjzqWJrX7G6y29S5i6L6HCIoVQvfWl74/cLiZVl66fHFKH/opm8Pd
m7lQeum/w86Y/Tu+26idG+bId2l1TEdZwF2nMOj97fk92SfTE2ChANhP0fi27XTL
t6s/sDQK1FOMHvuGg3bfEyDYC7lYe6JQTsz5L5aq3YVM6o0ro/Go4ebo0+cLt48D
9tKxJKMYgWHFhcF8QW05fJKPACaZhT8VuR3f/RhX64PJBsM4JEVwbuGW1T/mSwA3
7NoE6p95y+Mv2Xp5sKWJ1zMFi7p8YHrXc5pCBn0YnA7jlPr1PDttz3wMN32d1iSK
wWfjcpKqEqlqVKC/e7HT/7Krar7/VMrLCiBTzInWp9wi1fZy1iC3BF+yRUfdsCBt
CDR3bDrP3RJxgKvgPGCyZTYkplu75tX8ZSpwpuoYPF8VeOs630v+zOTMtg+FE2Mp
IhLoPFF6gmk=
=lsaq
-----END PGP SIGNATURE-----

--==_Exmh_1468252963_5025P--
