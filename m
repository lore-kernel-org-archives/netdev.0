From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v3 01/13] phy: add sgmii and 10gkr modes to the
 phy_mode enum
Date: Tue, 29 Aug 2017 13:27:17 +0200
Message-ID: <20170829112717.GC31552@kwain>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-2-antoine.tenart@free-electrons.com>
 <4c66e79f-d385-3cf5-6f24-2a4aec9fb3b4@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="mvpLiMfbWzRoNl4x"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, andrew@lunn.ch, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4c66e79f-d385-3cf5-6f24-2a4aec9fb3b4@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--mvpLiMfbWzRoNl4x
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kishon,

On Tue, Aug 29, 2017 at 04:08:29PM +0530, Kishon Vijay Abraham I wrote:
> On Monday 28 August 2017 08:27 PM, Antoine Tenart wrote:
> > This patch adds more generic PHY modes to the phy_mode enum, to
> > allow configuring generic PHYs to the SGMII and/or the 10GKR mode
> > by using the set_mode callback.
> >=20
> > Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
>=20
> Acked-by: Kishon Vijay Abraham I <kishon@ti.com>

Does this means the generic PHY patches of this series can go through
the net-next tree (once all the comments are taken into account)?

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--mvpLiMfbWzRoNl4x
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmlT5UACgkQXE2LyK3b
vNghCw//UV0aouzbdHXOfpd5kYkjWxClasPLKrgGCxShbgKgmTaGKBZq0ZFzJ8Wv
16ehZl/0mqu4wSVc+1ATQSi/2mr/6GYHJ3ecQ8ga6FRMFnrnCNJ+SwCh8jh1km3C
CJxe9Yf+uYcHNEqRVriRUfdfV/DZ7Aru7A3qrWlNgVh6ktd8VEoL+kM6tsP4/Qgd
tMyqYPcLcR8ph7Q4szGdb3AviNUyoGflvZ/2R+dUOI43ZG7lxtCE8QevwafSOucl
+gVMo0LljKWm9jYDpLD1UMk11qwO6Pf9usF7DH1lRZ6iyAE5yvFwgXd2TjIbXTVp
5qKaQs5fBSNmCjgIgU5womWKAgon06LLyD/PtRvtZsl1Vg2pza13Z4bsad0vCaHY
eSQJ5/kSmeWzcFb7rmxCpSZhNegXRwq/vjx7+1mhgXYPZa50yHU1Ww+Vr6D151bK
UIaHGGD6xE6Lxxn5ApUcXLqac0B4GbA22r5gcHHfg2HxT0q1jHYq1IYPFB/Dw7W2
y8RX3qw7X05UjB1w8XWKaET2lykUIDTyHyYZKH8HaYzIPU4S5dDs/PCh6f+SO77u
0wsqfTAdmfCs6vyCQFL+GL8cO9oiObkA8jOtQpBxuAfhXwt/scAzZi2dn9Ecb0IN
+cJ7+Jc42P5PWGQaR+geLMNQ2dT5MJUN7CUblrsnu/zoZIRa2FA=
=jK7I
-----END PGP SIGNATURE-----

--mvpLiMfbWzRoNl4x--
