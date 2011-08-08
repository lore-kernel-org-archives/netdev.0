From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: README: networking GIT trees
Date: Mon, 8 Aug 2011 17:32:03 +1000
Message-ID: <20110808173203.49f5e8f62f9d73f9e7f4ab6c@canb.auug.org.au>
References: <20110807.234027.1850968504654724492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__8_Aug_2011_17_32_03_+1000_oCbIBhun.=ou5INz"
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:36618 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753850Ab1HHHcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 03:32:14 -0400
In-Reply-To: <20110807.234027.1850968504654724492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__8_Aug_2011_17_32_03_+1000_oCbIBhun.=ou5INz
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Sun, 07 Aug 2011 23:40:27 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> net-next is now open up and all pending -next patches have been
> integrated and pushed out.  Also, the plain 'net' tree has been
> pulled into it.
>=20
> However I am freezing driver/net in net-next so that Jeff can
> have a few days to push his drivers/net reorganization GIT tree
> to me.
>=20
> Once Jeff's work is merged in, I do recognize that we will have
> some merge hassles any time a net driver bug fix is merged into
> the 'net' tree.  I will try to pre-emptively address this with
> quick merges into net-next when possible.
>=20
> This is just a heads up if one of these merge hassles propagates
> into -next for some reason, they are expected and I will clean
> them up as fast as possible.

Thanks for the heads up.  If I do come across one of these, I will still
report it (just to let people know what I did) but you can ignore my
reports if you have already fixed the problem.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__8_Aug_2011_17_32_03_+1000_oCbIBhun.=ou5INz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOP5DzAAoJEDMEi1NhKgbswwkH/jevTYR0QizZCofghQJ/najd
q3aQeKT/r6q0GBi5KVKTZv4hvvcs6zSKsLIeRHIASnbclIb1G7e67bZNQwmoODOi
/ss1H5qpclUTLiZeftfIJtMa3Zuz17PPZL8NbFuoJC7LdnAbxj4Rq8jElw2sw7L/
lWQrubU6m66t7mU2HHDO1s6PwLPf3bsB1DImQQgeAVTKL5Rcxe9niubk7v1sbHew
MK2KGCiZ32tGmCmicPf+8MKHRKyBWOOgGVDLV/cA9l1gJgquS3NisakPBtzK4RR9
1OGqK0mVTQQCUFwCzPzVSrlJ1/7CEek8rIeAFo9/LHfABJIpzrmgHmr24wt+/7c=
=5vcg
-----END PGP SIGNATURE-----

--Signature=_Mon__8_Aug_2011_17_32_03_+1000_oCbIBhun.=ou5INz--
