From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH -mm] Fix dev_load() compilation again
Date: Sun, 7 Sep 2008 14:08:41 +1000
Message-ID: <20080907140841.9ff05dc6.sfr@canb.auug.org.au>
References: <20080904224004.d3dd3076.akpm@linux-foundation.org>
	<20080905193244.GD11569@x200.localdomain>
	<48C18E8B.9050201@ct.jp.nec.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sun__7_Sep_2008_14_08_41_+1000_jA9N7vz/MwWt7A2q"
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:35811 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbYIGEJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Sep 2008 00:09:00 -0400
In-Reply-To: <48C18E8B.9050201@ct.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Sun__7_Sep_2008_14_08_41_+1000_jA9N7vz/MwWt7A2q
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Hiroshi,

On Fri, 05 Sep 2008 12:54:51 -0700 Hiroshi Shimamoto <h-shimamoto@ct.jp.nec=
.com> wrote:
>
> Alexey Dobriyan wrote:
> > dev_load() doesn't exist if MODULES=3Dn.
>=20
> Hi,
>=20
> in -next tree, this patch fixes the compilation error instead of
> my patch. So, there is a conflict.

My patch is a temporary work around and will be dropped if the fix turns
up in any of the trees that I merge.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sun__7_Sep_2008_14_08_41_+1000_jA9N7vz/MwWt7A2q
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjDU8kACgkQjjKRsyhoI8ybVwCdF45xa1p6DKZ6mBWjpYKF4AOu
PvoAoLHxhb8NxnE5cHZ4puiVY4W5Mmkt
=ThS0
-----END PGP SIGNATURE-----

--Signature=_Sun__7_Sep_2008_14_08_41_+1000_jA9N7vz/MwWt7A2q--
