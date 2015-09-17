From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v8 0/4] can: Allwinner A10/A20 CAN Controller support -
 Summary
Date: Thu, 17 Sep 2015 20:27:37 +0200
Message-ID: <20150917182737.GK4684@lukather>
References: <1442402482-7118-1-git-send-email-info@gerhard-bertelsmann.de>
 <20150917175444.GJ4684@lukather>
 <55FB028F.7070206@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Jaerp9zHWz52Eeko"
Cc: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>,
	wg@grandegger.com, mkl@pengutronix.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55FB028F.7070206@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Jaerp9zHWz52Eeko
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 17, 2015 at 08:12:31PM +0200, Oliver Hartkopp wrote:
>=20
>=20
> On 17.09.2015 19:54, Maxime Ripard wrote:
> >On Wed, Sep 16, 2015 at 01:21:18PM +0200, Gerhard Bertelsmann wrote:
> >>Hi,
> >>
> >>please find attached the next version of my patch set. I have
> >>taken all remarks from Maxime Ripard into the new version
> >>
> >>Please review, test and report bugs if exists.
> >>
> >>The patchset applies to all recent Kernel versions (4.x, next etc.).
> >>
> >>[PATCH v8 1/4] Device Tree Binding Documentation
> >>[PATCH v8 2/4] Defconfig multi_v7
> >>[PATCH v8 3/4] Defconfig sunxi
> >>[PATCH v8 4/4] Kernel Module
> >
> >Applied 3 and 4.
>=20
> Applied to what tree?
>=20
> That's not the friendly way when Marc asks you about the documentation ab=
out
> the device tree (patch 1) and you commit the CAN driver and the sunxi
> defconfig (patch 3 & 4) that he mainly reviewed to whatever tree.
>=20
> New CAN drivers go via can-next and net-next into mainline.
>=20
> So please answer Marcs question and let him queue up the CAN driver via
> can-next himself.

Hmmm, actually, I meant 2 and 3, the two defconfig patches.

The driver and bindings should of course go through Marc's tree.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--Jaerp9zHWz52Eeko
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV+wYZAAoJEBx+YmzsjxAgoNgQAJA769lQEPmx6R2siEogC4H+
5moHtwSTDxKXJYaAMMFNRYmCHH9SRzTpSn4ANeKkDSsMAHG42IbiLQv70egzE01O
aQsRq57Q4pXBmVUI0DBR+ZhdyCuqQpO0RIfrI1uG9nLE5ySf7Ui9ADH8IAjXGukb
ldihtG44haMzI3CUpq5KpwZs/03Bb+MIeq+7OoyYEwsb4K5GaLr7nB0YyzgLzHDd
pWjoj/Ja4ir1MOTV3thDhap5iwy8RPxMABYQ01lGIdK5+0F/ZXIcX1cHG2FEyc++
Qs0C6kDZKLD0wPudMO9DcDtoW4RnyDsXQPoxlI0281o3F+vzEjQHvfgUY156nQ6x
yDI/MCv3L9q43TYrr+bdEWihSh1O6FQKEB7wP9qW/X0RnaJb9DG9BjviW0NfsVNr
yyhb77x1ERRtvUoNb1OTZL9VB17HFzslGu/bb874ncZJsuqo9ojUIej9bo1XZN0U
WNt4BFGpeJkk+XbWSYlj47K8eEMpCdZsLk7hLpD7da51MMhkDrfSw8SgTzrgztYV
cuEM55U87XuIija9oUDjr5bt8W+m1vUrkdZeq91s0PKdtnxQxtj+r2bwBG0ZVLb3
PwGWY2QUM6nP/h2Vc3iVI1uMEgnWWowYT/W15dmUyEZvT0o/omtHf3nOx934enHb
PusHJWTwOxXJUHR0TIaO
=U3hC
-----END PGP SIGNATURE-----

--Jaerp9zHWz52Eeko--
