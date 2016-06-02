From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH iputils 1/6] start gitignore files
Date: Thu, 2 Jun 2016 00:42:50 -0400
Message-ID: <20160602044250.GN7717@vapier.lan>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
 <574F94B5.5040100@miraclelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="9a9Vq1BJdYBEXpLG"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:56828 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341AbcFBEmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 00:42:52 -0400
Content-Disposition: inline
In-Reply-To: <574F94B5.5040100@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9a9Vq1BJdYBEXpLG
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 02 Jun 2016 11:06, YOSHIFUJI Hideaki wrote:
> Mike Frysinger wrote:
> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> > ---
> >  .gitignore     | 22 ++++++++++++++++++++++
> >  doc/.gitignore |  2 ++
> >  2 files changed, 24 insertions(+)
> >  create mode 100644 .gitignore
> >  create mode 100644 doc/.gitignore
> >=20
>=20
> files under ninfod/ as well, maybe?

perhaps ... i've never seen this dir before.  it has generated files
committed to the git repo though which kind on conflicts with using
gitignore.

maybe merge this and then wait for someone who actually builds/tests
ninfod to submit an update ?
-mike

--9a9Vq1BJdYBEXpLG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXT7lKAAoJEEFjO5/oN/WBkFMQAIs+4UE79or721n5RsrRepl1
Ss29IfZMV8BmLqmGXUejBm25FMUKhCl+5zGFpEyoizbTGiFoXdKhrySHhTW/IrZ5
u8YFdfeHVHj9kDepc+01Z9YCR5XumySk6vktnQ/VI/j/KQefZNZM9Eh61+YHfcAh
9M4bYOjUtfbAPuEU+0W34NLOe71A9iTWmSqE3JIXTnAoXSmO4Xq4auw9m2xjMV+3
fgFHaDcYMFDuzKFBH8FNEepMbmaQ4MIIHcfr8ij/V9bE4b90d90k2orerxUlT6Fw
hNa5VnJxuvSl3MuKZOTtyxDdQ+oO+Vx3EKrsJyncklAZLI1Sv9ZfYLK0T76qQebp
MclzlN00XMns0LMBTjnPDxBBDGyZIE0ek1+I8MpyxlMYPOIbpg5hTXjCjuvMTX2p
AsXJPH0HVckD732YgLxb0sjp/DMLaPrt7uDsrW5y/PE5ofUy6Kq6oEoeldC+Tx17
6+h7x7aJ3NUdiqDwtrQfyBFbpXomkcX3nc/oVNT4p+qWeSn69N2UvKAz55RPCBgt
oh68F7rPMRS4Y2SuE8yjQYvi4v2aK96YYcEvh1BBSHH/+gAaGCzCldB5feDV8R9N
xZB71yirpFfVgQyaykgfMfryirKe5lNlvIYLJa3U5DvP/SA1bQglG1S1NHKuo0Ga
1zV/U6s6XbhM0Jn03QJd
=qE69
-----END PGP SIGNATURE-----

--9a9Vq1BJdYBEXpLG--
