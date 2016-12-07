From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/1] ixgbe: fcoe: return value of skb_linearize should
 be handled
Date: Wed, 07 Dec 2016 09:30:04 -0800
Message-ID: <1481131804.2404.10.camel@intel.com>
References: <1481096614-25295-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-fstTrj3LKi4XZEAT7ZWY"
Cc: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481096614-25295-1-git-send-email-zhouzhouyi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fstTrj3LKi4XZEAT7ZWY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-12-07 at 15:43 +0800, Zhouyi Zhou wrote:
> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
> Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
> Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>=C2=A0
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c | 6 +++++-
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +--
> =C2=A02 files changed, 6 insertions(+), 3 deletions(-)

Did Cong, Yuval and Eric give their Reviewed-by offline?  I see they made
comments and suggests, but never saw them actually give you their Reviewed-
by.  You cannot automatically add their Reviewed-by, Signed-off-by, etc
just because someone provides feedback on your patch.
--=-fstTrj3LKi4XZEAT7ZWY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYSEccAAoJEOVv75VaS+3OR8wP/jer9Z/yWPhLKGcefyTCPOyq
e3NIBBYTTumg2iba/J4xToAU05GPCJmpTqxFGK2/axDAdS9Zo4L1E6KMoT6k/PRH
J18WQEDOG3uuoNyCQ3O4QAmaJhiDX9/iM6pYwdISO15kS7PSVERVL43UcDWQfCP8
ZagCz/JMzgvV5dYp/3aELoAGMPby0fklny5eSx0B2orWoSFnXah5vQiSfQGQT73m
cjukkZ32JRZmzgZUSm9NWcwy1f6bM0FUGEe+a9p9Bz9Pej+48VtGsy0Mdc9zd8mL
mGZ136MszDgpzqwZyR8XQPFpZpr7DW9lR2XWljejE3QfkFYr1ovgp60ikbezm+zA
4Pj/g8kXlKEntDhLlg2jifGxLFZTZsEb3LPIis3XHJ4VBTvfZXnt/ksX+vJw9sTk
njX9qSD4nwVSoDnyeXEcW33cWgT8fl83GZKodgEY0GqhTTHKhAVB1KXfRQtWzauK
V4KqH0CaVlRhlXorKiZeu7KpszTCLF6ZDzQk4NP/6knQ342eyfw0czN5+DeahWGa
xPXo4HylGV8rP9Xl9iNvxJnlPTFIF5zoxNOc5+waaZ270+oU75ctchcGxvZxYXXM
GfJVfmcPXpwFggcsqE8iWvNpVndTcmkaqFB1tpzVBE857gcneVIu9z2IRELgnVck
PQXSQHqzwA4RB80k99Aq
=x9Io
-----END PGP SIGNATURE-----

--=-fstTrj3LKi4XZEAT7ZWY--
