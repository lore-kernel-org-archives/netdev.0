From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: manual merge of the net tree with the unicore32 tree
Date: Tue, 23 Aug 2011 02:00:48 -0700
Message-ID: <1314090049.2128.224.camel@jtkirshe-mobl>
References: <20110823130210.766d466d689d60536f59340a@canb.auug.org.au>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-W+XDVwSmhfwnh1HElvCB"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Guan Xuetao <gxt@mprc.pku.edu.cn>,
	Zhang Shu <davidshuzhang@gmail.com>,
	Chu Xiaowei <chuxiaowei@mprc.pku.edu.cn>,
	Su Yonggang <tonyhook.su@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110823130210.766d466d689d60536f59340a@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-W+XDVwSmhfwnh1HElvCB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-22 at 20:02 -0700, Stephen Rothwell wrote:
> Hi all,
>=20
> Today's linux-next merge of the net tree got conflicts in
> drivers/net/Kconfig and drivers/net/Makefile between commit
> e8787de6fa83
> ("unicore32: add pkunity-v3 mac/net driver (umal)") from the unicore32
> tree and the network driver rearrangement from the net tree.
>=20
> I just added the new driver from the unicore32 tree commit into each
> file
> (see below).
> --=20
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au=20

Hmm, well with the latest series of patches I sent out, I am pretty sure
this patch would not apply.

Is it best that this patch not be sent to netdev for driver
inclusion? :)

--=-W+XDVwSmhfwnh1HElvCB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOU2xAAAoJECTsCADr/EWU74kH/2f94oI8OdRxQM/90ykvE9cZ
pPUZwBTCL9DvQ04TKNzASk153R6sNTvfa8glf5kp9UemHETP+xtCLwE9YQNX5eWJ
jqGHtRm2BovqvUV52WiHFfNbrbtqUGoHVpBDp0JcFA7paoC6KXU8EwCatToy4Fel
lEA0vzRSXUEYpLQyVMt9WiQIMCyTy/ORhNOc8mOMJ3sNUlAng/kx0u0VjSAhgn0W
aKMbmT8FsDH9/9fyqmZXbHZp4pXydSCbhSxTPbXHr7M1vAJahvQn+7yHLLyuZNbu
UVSUO6NzqRpLOM62+UsbX7jm1iRVpToMUd86Jqgma0TLbRh26X61JNXp/Ctg9Ec=
=6Jf6
-----END PGP SIGNATURE-----

--=-W+XDVwSmhfwnh1HElvCB--
