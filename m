From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgbe: Remove unnecessary #ifdef
 CONFIG_DEBUG_FS tests
Date: Mon, 08 Apr 2013 11:47:36 -0700
Message-ID: <1365446856.2048.0.camel@jtkirshe-mobl>
References: <1365384453.8922.20.camel@joe-AO722>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1wKvR3kMdNqpigQkadmL"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57142 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935047Ab3DHSrv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 14:47:51 -0400
In-Reply-To: <1365384453.8922.20.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1wKvR3kMdNqpigQkadmL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-04-07 at 18:27 -0700, Joe Perches wrote:
> Add some empty static inlines instead to make
> the code more readable.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  5 +++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 10 ----------
>  2 files changed, 5 insertions(+), 10 deletions(-)=20

Thanks Joe, I have added the patch to my queue.

--=-1wKvR3kMdNqpigQkadmL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRYxDIAAoJEOVv75VaS+3O+CAP/RLSFAcsoh6VRME1TkeSDbYt
oSfGkjpN6ZpX0joQJT06Yu8H7mVljP+fPW68eMacyXW/gae+eDknKHCtwsRA9agd
8CRRBnOySsQjdOuCsNceWn5SW+jwWH7iTPg+cRt2Ky3x49nlgspbpfH913o2icFT
7VMGQsCm/aoQiKiYRUZDK1/IMpHRRlMrQ9qRhC4Vwz0T+K+kiaiLRlxUQHgwsx7S
hrcJZojVG80GDXYVOgZLtgVm/QoulVxfjvWFMAdNlaU9XmwAcedI+kQv+eROxzo4
G2shMWRKmmoPPaJ3hokBJgS+1CPbPbfh/8gHeZhKi5/UbiyueSKE5FFCID86m2N2
p++AnqCjFOACeJfH892LX8HF69xG/WLvQrbDbG6Gp3+E17cYSPofbnIRwrk16ZMx
FfD+QEHwsL4SyVVeG09ofWH8XKzTVx35ucej/Pzv/jBB7cYPui+CEu8J6MVHuShU
iVkZhh4CkdrIYDKgXx1loW3HUC89YZ8MOf4Hy7Wxw6JuFrVzPD09y8wOyax6Zt30
NSaJoGGfFO2ldqlbY92gubbwugLEklmZe/3oO6iFWjXkXSOdhrrqxAnxqEUFJAzr
aLxEvLJ3XIJufRYzNnGjGk2/yCoJTxzLcpSm21BAvuw9VfdAQzGn2RQr+iLiiDbX
CdbJ7WVe/0EQ6+/gEIq5
=mfY+
-----END PGP SIGNATURE-----

--=-1wKvR3kMdNqpigQkadmL--
