From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH net-next 0/8] etherdevice: Rename random_ether_addr to
 eth_random_addr
Date: Mon, 16 Jul 2012 14:12:19 +0300
Message-ID: <20120716111218.GA4913@arwen.pp.htv.fi>
References: <1341968967.13724.23.camel@joe2Laptop>
 <cover.1342157022.git.joe@perches.com>
 <20120716101437.GC22638@arwen.pp.htv.fi>
 <20120716.032901.1657058688119342783.davem@davemloft.net>
Reply-To: balbi@ti.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
Cc: balbi@ti.com, joe@perches.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, wimax@linuxwimax.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-s390@vger.kernel.org, johannes@sipsolutions.net,
	uclinux-dist-devel@blackfin.uclinux.org,
	linux-kernel@vger.kernel.org, linux-c6x-dev@linux-c6x.org,
	linux-mips@linux-mips.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120716.032901.1657058688119342783.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Jul 16, 2012 at 03:29:01AM -0700, David Miller wrote:
> From: Felipe Balbi <balbi@ti.com>
> Date: Mon, 16 Jul 2012 13:14:38 +0300
>=20
> > if you're really renaming the function, then this patch alone will break
> > all of the below users. That should all be a single patch, I'm afraid.
>=20
> It would help if you actually read his patches before saying what they
> might or might not do.
>=20
> He provides a macro in the first patch that provides the old name,
> and this will get removed at the end.

that's why I put an "if" there. The subject was misleading and I really
couldn't bother going search for the patch on the mail archives.

Anyway, if nothing will be broken then for drivers/usb/gadget/:

Acked-by: Felipe Balbi <balbi@ti.com>

--=20
balbi

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQA/cSAAoJEIaOsuA1yqRECgMP/11LX6hhvLwodK9V12dXWUI8
n4rD9q+ipGtPf/S551hE9jkkp4yCPUromRhx5hgbmaDJ23ZbqHpRR3fNNHSGpH1W
xSdS7vdtqWxpt7LUqczpgbjstrFqDYEt5idkuUsQ3QRZEZ5NgeTigWYEiIpf6uPQ
qy1YgtmJZlPJKskiH+8YdDGHgL3vI8iypfk7GBVwBYp7ozl7LyqM62mpbSMPxQGr
uAx/FEFC2o31p/B81WkGzFiq2vc7oy+c+IvfWre+mI7X6+AyiAGR719CI0V7umQD
iMK/yrncbbuBCEsCdLN446kkRocFYX/IDiykTYHc2/V4WDxJO8wYH0gTSdMJOxDG
fsxrUS9RUAb0vyGRaUvTMHKhQdo5ijBhkWHvoL7jjyqaCEvYqarRDhqZq6uW6t9E
AVNxmUriH7Iflw1BiRJk03IO3/dFOY2b5yCTmSwklNdXuuL52biuRe3PIK1mDli9
F2sr5xj/VuT66HNTbOI4tFH53yhakkYjSffVK8xs2GuBvsTr1RiLBQT2YK3yU77Z
Pk798mAkIhUhlZh998YRlJHtqs9JkyeHIHTuSt7Zj/FJmWaDLfjMAa18knsuFAFg
tYnpnP3mtGE12FeXQ0rGcnqrsqWjIy8NKnNjf9DqNc/DwmjnyL/UMsN0J+m9/uaF
kyn8nJ4loji/LHjMvX2g
=BzOs
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--
