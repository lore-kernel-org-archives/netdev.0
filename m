From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 2/3] if_link: Add VF multicast promiscuous control
Date: Thu, 19 Feb 2015 20:04:23 -0800
Message-ID: <1424405063.2979.11.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38840@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/RvMjPtjtu7uMDGHEuoQ"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38840@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/RvMjPtjtu7uMDGHEuoQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-02-20 at 01:00 +0000, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> Add netlink directives and ndo entry to allow VF multicast promiscuous
> mode.
>=20
> The administrator wants to allow dedicatedly multicast promiscuous per
> VF.
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  include/linux/if_link.h      |  1 +
>  include/linux/netdevice.h    |  3 +++
>  include/uapi/linux/if_link.h |  6 ++++++
>  net/core/rtnetlink.c         | 18 ++++++++++++++++--
>  4 files changed, 26 insertions(+), 2 deletions(-)

I have added this to my queue, thanks!

--=-/RvMjPtjtu7uMDGHEuoQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU5rJHAAoJEOVv75VaS+3OfxQP/iUzcTNSYLrlXMbUv8d8PRW3
zEuFMQfRdEjLtuXMQW0tPCm97/Gote2XJ7cdaSycFMtL9fcoKnDSqqo3BpFQ//D1
5fMfNfXCmoUgD1fZtERJQt1I31tVJj9siX+xYejvNvyMkferfd6osB5epXd2DNNG
uO8F3ECXqTkE91braHwbYktkM307+6/P/7qi35fQ/CXWX5dBTxz0OxAS7YomH0g0
A0bQtZZ9MQpsA5Yuip+dQBv+dm6mrlRvHgPHGkp84GXGRBEf6Nnvm98skX2kYJsK
fDvVRFJQZUrmI34stWudfee8xJpsCaOHFP7fy4eDxzG7eTmJVQYErlGqYXuyrQeN
TOEhcOVWise4y3A0tzTP6ny/O1RBc7yjpy1nzzYJosd16jjHWJGBZHbhsK3cRdbD
TiSpUJARwTbFqMrdKtATtfWoA6NRUcTh4foVu4bDT1M20HTrVXOu4bG6i7Ln95e+
Ttb1nmcoiroye8Jy5QDw943nbVQ6dhgBwkLjW3Tv8dx1Y45zps2AfhImETJ/xxBW
p5AYUgWsECgBbHk8/V5du9zILvdAMRDZiufJ3AvPaoY8F9WsWzZ5qaw/wMDlVimx
Wypsi2phoy7hZj8zuOI6YMVS6jwv7VUhwvmEMyXFzJvPJtgAMb39A5QwYonV8VHa
5IyWu3nREOCRFNRhD1Ai
=amnf
-----END PGP SIGNATURE-----

--=-/RvMjPtjtu7uMDGHEuoQ--
