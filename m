From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH (sent originally to netdev)] device: Add
 dev_<level>_once variants
Date: Mon, 17 Nov 2014 18:23:44 -0800
Message-ID: <1416277424.2295.1.camel@jtkirshe-mobl>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5467C3BA.6090003@gmail.com> <1416277102.29010.14.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nuj0z72yUvFcRP5VA+FK"
Cc: Greg KH <gregkh@linuxfoundation.org>, davem@davemloft.net,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416277102.29010.14.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-nuj0z72yUvFcRP5VA+FK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-11-17 at 18:18 -0800, Joe Perches wrote:
> Add the equivalents to pr_<level>_once.
>=20
> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  include/linux/device.h | 35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)



--=-nuj0z72yUvFcRP5VA+FK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUaq2wAAoJEOVv75VaS+3ODrYP/1nksBh55gk473t8nrZaUxYh
ENxbIQudN3Fj4uwM0sA2aErLlbebHADwWf4YeNT6dkx/xZOElpIi1DrHTB4gVXko
ii9a6w9/4Q/E86pQBZJ0rF3qr7GrvZZv8ZHbk1IPEpLbdIsUrfVnREkAIwzVqb1g
b/kaWEl/I7XFnn0SoKdTB+0KmDNGyzAWdo1kqF78z05k1m4Icyf1JpaYUIx4y/ct
cIe0IbSeBs89vS3mi7hykhPAr8pH0hCsaJ/3e7EgID8t5DUCND/T6LHNhAK3h9M/
QHswGg0OCocimGBG+yHAXQIz6uKQKdUN2KW165OnBhpMhoSiTzzF/1akhwrCDrGk
oTGhzzb4X/pGc31JRkzzFPiSoCnm5BowG4AzH67gVuahoinyya3qMQajy8cyoHwh
Xvx5w36ZZxI6mLnkwfHchM3XT1qvO0Rg6EdwyFuGc8dobgzHZ6gBteCREhPoPmr8
Y6BKT0aNzkkYYY41VT+IArZYUUB1WiNyIH80tsuFX7rT/yUOvpc2+Z+ENLR8TwKA
Yj5xccbu+B1nuSMjeinSxQX/by05WUZu82gxyVmswfNx+8ioQTEs/3+UCgpbVRq/
dsLj88P0I8CQAwNpMHc3fJsSHg52KkGbUjY6imF7N48ucmpooiCggl96o3iVt3+W
x0tBSVyKhSpDdQlkcTyw
=LTym
-----END PGP SIGNATURE-----

--=-nuj0z72yUvFcRP5VA+FK--
