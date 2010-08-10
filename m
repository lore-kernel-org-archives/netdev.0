From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: i386 allmodconfig, current mainline
Date: Tue, 10 Aug 2010 10:15:21 +1000
Message-ID: <20100810101521.0dcd4393.sfr@canb.auug.org.au>
References: <20100809164346.6e30cf8c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__10_Aug_2010_10_15_21_+1000_jSnD2iwR7XKMUyCj"
Cc: Greg KH <greg@kroah.com>, David Woodhouse <dwmw2@infradead.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Kevin Curtis <kevin.curtis@farsite.co.uk>,
	Phillip Lougher <phillip@lougher.demon.co.uk>,
	Faisal Latif <faisal.latif@intel.com>,
	Chien Tung <chien.tin.tung@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Samuel Ortiz <samuel.ortiz@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, x86@kernel.org,
	linux-rdma@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:36685 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757268Ab0HJAPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Aug 2010 20:15:31 -0400
In-Reply-To: <20100809164346.6e30cf8c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__10_Aug_2010_10_15_21_+1000_jSnD2iwR7XKMUyCj
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Mon, 9 Aug 2010 16:43:46 -0700 Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>
> Guys.  What's goin' on out there?

I guess we are all so up to date that noone does 32 bit builds any
more ...  Also noone is bothering to look at the build logs:

linus tree: http://kisskb.ellerman.id.au/kisskb/branch/3/
linux-next: http://kisskb.ellerman.id.au/kisskb/branch/9/

> drivers/power/olpc_battery.c:387: error: unknown field 'owner' specified =
in initializer

This is known and should be fixed in today's -next and hopefully being
sent to Linus.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__10_Aug_2010_10_15_21_+1000_jSnD2iwR7XKMUyCj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMYJoZAAoJEDMEi1NhKgbspiAH/2C3J61hGSMp61JCgcjbUVwU
0lK/8yzWhFqF0PXg1c5ELIm3j2UeRjO9FPYkU6fFaple5GX2mJmoP56TcfDjTJzz
7uDmZNLr8juarntzwml9knQ+OyNmYBR6ywl/tevniFHCDbSRYsvaFp/TRp3IL/3z
0ce83Sw0ZPZHML2pN2IMBsYNm/FhKG0agdqhywmaQStEUHJeVWGnCNzNn4fCqiPZ
b0/p/1ri8fsBv3GTy9It6hd096Ndvqt4erqpvqez2tOb4AmeRR6Dng7ygfoGyjat
ppEzB/YUi8u5a+TGc7t6Eoew4UIspNq0MqHdS9lAnl3PhpPnuQpRu31B+CUoel8=
=0nDF
-----END PGP SIGNATURE-----

--Signature=_Tue__10_Aug_2010_10_15_21_+1000_jSnD2iwR7XKMUyCj--
