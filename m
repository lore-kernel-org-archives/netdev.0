From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [PATCH] batman-adv: Remove unused variable
Date: Wed, 6 Feb 2013 23:10:22 +0100
Message-ID: <20130206221022.GF6008@ritirata.org>
References: <1360168661-16871-1-git-send-email-emilgoode@gmail.com>
 <20130206172234.GB6008@ritirata.org>
 <1360173353.22154.4.camel@debian>
 <20130206195557.GC6008@ritirata.org>
 <1360187945.25903.5.camel@debian>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="QNDPHrPUIc00TOLW"
Cc: lindner_marek@yahoo.de, siwu@hrz.tu-chemnitz.de,
	davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Emil Goode <emilgoode@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30695 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757205Ab3BFWLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 17:11:16 -0500
Content-Disposition: inline
In-Reply-To: <1360187945.25903.5.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--QNDPHrPUIc00TOLW
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Emil,=20

On Wed, Feb 06, 2013 at 10:59:05 +0100, Emil Goode wrote:
> Hi Antonio,
>=20
> If it is easier I can keep an eye on when the commit lands in the
> net-next tree and then resend a modified version of the patch.
> Or do you want me to resend it now?
>=20

Well, that commit should be merged in net-next after the next merge window.

You can resend it now, but be sure to CC Stephen Rothwell
<sfr@canb.auug.org.au> (the linux-next maintainer) and to clearly state tha=
t the
patch is for linux-next.

Thanks.
Cheers,


p.s. try to do not top-post please :-)

> Best regards, Emil
>=20
> On Wed, 2013-02-06 at 20:55 +0100, Antonio Quartulli wrote:
> > Hi Emil,
> >=20
> > On Wed, Feb 06, 2013 at 06:55:53 +0100, Emil Goode wrote:
> > > Hi Antonio,
> > >=20
> > > The commit ed242d01 is in the linux-next tree and my patch depends on
> > > that commit.
> > >=20
> >=20
> > Yes, you are right. I was not aware of this commit, because the author
> > did not CC us (neither netdev) even if he changed the code we maintain.
> >=20
> > As far as I can see that commit is in linux-next only.
> > Therefore it must be applied there.
> >=20
> > However, I'd like you to change the commit message and write the full h=
ash of
> > the commit you are referring to and its subject ("LIKE THIS"). This wou=
ld make
> > it easier to find it.
> >=20
> >=20
> > Regards,
> >=20
> > > Best regards, Emil
> > >=20
> > > On Wed, 2013-02-06 at 18:22 +0100, Antonio Quartulli wrote:
> > > > Hi Emil,
> > > >=20
> > > > On Wed, Feb 06, 2013 at 05:37:41 +0100, Emil Goode wrote:
> > > > > The commit ed242d01 removed a node parameter from iterators.
> > > > > This patch removes a hlist_node struct that is no longer used.
> > > > >=20
> > > > > Sparse gives a warning:
> > > > >=20
> > > > > net/batman-adv/originator.c:411:21: warning:
> > > > > 	unused variable =E2=80=98node_tmp=E2=80=99 [-Wunused-variable]
> > > > >=20
> > > > > Signed-off-by: Emil Goode <emilgoode@gmail.com>
> > > >=20
> > > > On which tree did you base your patch?
> > > > I cannot find the commit you are referring to (ed242d01) and the pa=
tch does not
> > > > apply (neither on net nor net-next).
> > > >=20
> > > > Other than that the variable is used a couple of lines below (in th=
e code we
> > > > have)...
> > > >=20
> > > > Regards,
> > > >=20
> > >=20
> > >=20
> >=20
>=20
>=20

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--QNDPHrPUIc00TOLW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJREtTOAAoJEADl0hg6qKeOyaQP/jCQKa02ncoLM0iB/GbxpB8k
jK9e8IQkHYDQyix2uV8Pd0xrfx9gSstWImOS8arXPJ3cqa/aKraNTVISnyg0ZHRM
7+qBs+bDa2b9gUsS1RztYDefovYxK2lsU4djo1cW+MgDR3JR0x8e0/U1ZLRpDZhh
2Hm/ZfKPunYGUtbGkKlvBrzuglKTJyxPAs316w3RHTB34KXAN3jP+zYMPqtv4dIu
nNvpBEKPNYsIGYg3BsnVA6JmFQCPMymBUYkkD7LpXG9c2e/1ESd9Eh8UGbyx/fox
odOVWxO8EWO71Flsha0bMyqL98K8M071XfyCmDyCC4L8uc+EyZ4O9VYii7GEUZ7J
3V/dnyU0TI132zgOGY/WX9T8T8iVaV1uRUfriaqd+pVq2lFDPg8SBhJQmBNt1KeB
ZVWsyl4yeJ43XED3fvTVIbHKZk7B7YXul3Ht0+DwEpsNECfuLd+BiXOT1nPwXuqw
5sFi14nO+0I8m9oPstfoQO5TVCLIAE+IifyxUTSgUJXbdRsKJ8DrlSDXguoozafB
o+NOHCrqO39PnagfjSglWoxJbTGwdQOpw4jNUvuBBcRl0PeP1N3jBgaBIsvQBHME
ci1SUgJGdw2TibztP0+CpkImEHqlrMUz2cOSxbYRe/ObdZQmAdgvBUzPQ1Djysjc
Pjyt7DMlji9BsmSNrVgm
=wQjA
-----END PGP SIGNATURE-----

--QNDPHrPUIc00TOLW--
