From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/2] igb/ixgbe: Fix ordering of SR-IOV teardown
Date: Mon, 03 Aug 2015 15:51:08 -0700
Message-ID: <1438642268.3467.8.camel@intel.com>
References: <20150727223753.10121.78169.stgit@gimli.home>
	 <20150729.121630.2264285348757503000.davem@davemloft.net>
	 <1438198387.13460.68.camel@redhat.com>
	 <20150729.143141.657802657776347202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Znj5ZkUWedCLUKj/o3HY"
Cc: alex.williamson@redhat.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150729.143141.657802657776347202.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Znj5ZkUWedCLUKj/o3HY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-07-29 at 14:31 -0700, David Miller wrote:
> From: Alex Williamson <alex.williamson@redhat.com>
> Date: Wed, 29 Jul 2015 13:33:07 -0600
>=20
> > I expect that's because of this patch that's in Jeff's dev-queue branch=
:
> >=20
> > http://git.kernel.org/cgit/linux/kernel/git/jkirsher/next-queue.git/com=
mit/?h=3Ddev-queue&id=3Dddf766a812a13eca1116b5905e902184904266f9
> >=20
> > I based these patches off that branch, assuming they'd take the same
> > route and avoid the merge conflict.  If you'd rather take these, I'll b=
e
> > happy to respin.  Apologies for not noting the base branch in the
> > series.  Thanks,
>=20
> No, that's fine, this would normally go via Jeff's tree anyways.
>=20
> I just didn't see him take it so I assumed that it should go via me.

Sorry, was on vacation last week and cell coverage was spotty where I
was at.  I have picked up the series.

--=-Znj5ZkUWedCLUKj/o3HY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVv/BdAAoJEOVv75VaS+3OHX4P/2A8GRtZgjCKmHUJvxOm8F8D
r84JE02DvkVuSwPGYxGePBXmJ9y+IGljGKKnx51mEjimLaGbnc7O+mHaJzPduXxR
Kvvbyf4u7wPhei2eqRq7b9HF6rLiP9N7HoadJJ0ZFXA5FJqryH0u+tbpQ6yTxGUH
Gw8xJf/YDfuvageb+Q5kejeKSQx8IoJsfvK4d+ZMDEhjwp0vgP8g+qzDgYqnrKnW
L9v9Ah6lr/ISF4Ds9do8t+GCWDO9BolS0eMY+cwIhvJC6ymkJpIMRtfaXVmSS1tl
LTg0aHan+IBOv6LXiwTdh3oQan6/yW3nw1Y9ocnIr2qGT/+LPjg89GmNF48wuXT2
6pnTjHdnsPDpwnFvtKrOxX3Xhyxh1lHeRQkyEq3plJ/VLRIjV6H+8DY+s667DKYm
3zkY7q73B+OihGgLp6JRf4mYJRvzSjk9N5b9p5/AX1fCk1X2STH84r1ASnnii42J
hIDC7dOEFUbttb3oGYwxLRHlhT+KWr3fHv22JBbAs9RELWsZnqWXOOoqM/UNLHit
+9p7lkeFbtYngaG9KkP+85MOxfTz+Kjaos7caPt59goAD6Q8wIvkFOFYPk4TLPXj
CvVYHhlONDgXgBZc8ZtJ+hjpj11U+6R1ABTrXlFuy4L/4wjVsIQI9EUy4Ac/BNlr
hc2sHyt86EXwKJrp6s94
=KibN
-----END PGP SIGNATURE-----

--=-Znj5ZkUWedCLUKj/o3HY--
