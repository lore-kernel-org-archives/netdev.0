From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Wed, 21 Jul 2010 13:44:29 +1000
Message-ID: <20100721134429.93730e40.sfr@canb.auug.org.au>
References: <20100721120448.31e325fd.sfr@canb.auug.org.au>
	<20100720.202759.00438343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__21_Jul_2010_13_44_29_+1000_fPHbP4i+HVQ1W5Fo"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:44440 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933266Ab0GUDod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 23:44:33 -0400
In-Reply-To: <20100720.202759.00438343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__21_Jul_2010_13_44_29_+1000_fPHbP4i+HVQ1W5Fo
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Tue, 20 Jul 2010 20:27:59 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> The net-2.6 changes should be undone as net-next-2.6 has the fixes
> that allow bridge netpoll to work properly, thus in net-next-2.6 the
> net-2.6 commit is completely unnecessary.
>=20
> I did this when I merged net-2.6 into net-next-2.6 about an hour ago
> :-)

Excellent, thanks.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__21_Jul_2010_13_44_29_+1000_fPHbP4i+HVQ1W5Fo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMRm0dAAoJEDMEi1NhKgbsBKMH/AsmKeS6+Ict0TeeThoKY/W8
CwnnvCIVs8rP0DvXeC4Nk0GFEKVJC3We6Jouw6vUtaGLCs95U8ewT5eMMXq1XBou
A0lXDmT7/CcOu7L1taTxhsD1bCYvh9lgwcZjXELHLyOGJWOO8nJJEktwnkDjm/WT
xOvbuvAgcDvi8y+D643A2OoqegsKwQ/VqCOH3SP7RskE1PBOQCODhiStYEXIsjBZ
tToIDc5BD6QjNieUL4OpWSoFf2GcBTnvnU5zpL1JsQsLkOuPrLLuRm2+9C80/zcX
R1jO5T/feRhOMti3+EW/k9PacEqqqcU1uXa3RU8MU8lBwwfY0+xPBcd7i+kSeHM=
=HJud
-----END PGP SIGNATURE-----

--Signature=_Wed__21_Jul_2010_13_44_29_+1000_fPHbP4i+HVQ1W5Fo--
