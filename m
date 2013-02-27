From: Petr =?utf-8?Q?=C5=A0abata?= <contyk@redhat.com>
Subject: Re: [iproute2 ] Fix compilation error of m_ipt.c with -Werror enabled
Date: Wed, 27 Feb 2013 15:53:29 +0100
Message-ID: <20130227145329.GE19542@rincewind.usersys.redhat.com>
References: <1361905927-31534-1-git-send-email-subramanian.vijay@gmail.com>
 <CAGK4HS_uu6RLBqHYrq181Jd0p7HCC=_W2ziQaeQQHhEWfazdNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="C94crkcyjafcjHxo"
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760001Ab3B0Oxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 09:53:32 -0500
Content-Disposition: inline
In-Reply-To: <CAGK4HS_uu6RLBqHYrq181Jd0p7HCC=_W2ziQaeQQHhEWfazdNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--C94crkcyjafcjHxo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 26, 2013 at 11:23:45AM -0800, Vijay Subramanian wrote:
> On 26 February 2013 11:12, Vijay Subramanian
> <subramanian.vijay@gmail.com> wrote:
> > Commit (5a650703d47e10aa386406c855eff5a593b2120b Makefile: make warning=
s into
> > errors ) causes the following build error.
> >
>=20
> A similar error occurs for misc/ss.c

Yep, also in misc/ifstat.c and misc/nstat.c on ftruncate() ...

P

--C94crkcyjafcjHxo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iF4EAREIAAYFAlEuHekACgkQT+hZYwG3Kb52EgEA0rz+srFLF6hEmaYJV6qVgEnU
0lIpYAnFLJr9XfnFoeEBAIKJRersm300lvxud38pEj8Nhzwv/aTuOPutZ6TOkrtZ
=nG5u
-----END PGP SIGNATURE-----

--C94crkcyjafcjHxo--
