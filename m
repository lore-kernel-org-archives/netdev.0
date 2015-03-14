From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: according net pull-request - was Re: [PATCH v4 1/3] can:
 kvaser_usb: Fix tx queue start/stop race conditions
Date: Sat, 14 Mar 2015 15:15:20 +0100
Message-ID: <55044278.3010606@pengutronix.de>
References: <20150226152011.GA6075@linux> <20150314130249.GA20796@linux> <55043A7E.7040001@pengutronix.de> <55043F64.9050504@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="SbBsw0IwKtCPQKXuuj06cwhnJshAv23TW"
Cc: Linux-CAN <linux-can@vger.kernel.org>, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Stephane Grosjean <s.grosjean@peak-system.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <55043F64.9050504@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SbBsw0IwKtCPQKXuuj06cwhnJshAv23TW
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/14/2015 03:02 PM, Oliver Hartkopp wrote:
> Hi Marc,
>=20
> On 03/14/2015 02:41 PM, Marc Kleine-Budde wrote:
>> Applied to can. This will go into David's net tree and finally into
>> net-next. Then I'll apply patches 2+3. Nag me, if I forget about them =
;)
>=20
> Stephane sent an oot-driver to me for the new CAN FD USB adapter driver=
=2E
> I splitted up this driver into three patches for a review from Stephane=
=2E
>=20
> I would suggest to wait until Tuesday so that we can add these three pa=
tches.

You mean for the pull request? I'll be quite busy until Thursday, for
#reasons, maybe the whole coming week. So I'll send this pull request
and make another one after Stephane's review and of next week.

> I tested the patches and they work as expected. But Stephane should tak=
e a
> final look at them.
>=20
> Would it make sense to post the splitted patches on linux-can right now=
?

Sure - Fire at will.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--SbBsw0IwKtCPQKXuuj06cwhnJshAv23TW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVBEJ8AAoJECte4hHFiupU+3AP/RkFf4qsN85uMSXjY9lpQz01
/ehYzwiGa0jtMDPY7ZH+fdaV+vMNkPEq2Id2hFA+9Onoy5NzSI9GFKfboUMDC6RI
l9OEPqHQDismDQch+/JtFkri+8k7Rb9a6NLKX5dLhkCSqRVVZ32JKRsyeYpnkA/J
xRsBxMbt050S+LOmsnxORdTMUjpo1WAVMUjjNu9O8Wz5Je2GRNLI3EUgYYwOts50
0T3wV1vHMgn6E0EB0wdPPxrT0pYMjeA6wO5KuwblyqnMKzeRoIKDxUbP0DD3KgV7
+4EiUPZEwg1CdhHmaQYKfJxvkrc+7u/6BOce8IdyzD7OehYv30mLuL49DWEEyqxg
BUn8MfNAbkKfZOLG2eTiu2ak4dhvsjc1nYHYhiUSeNMI9yVy/3QoP41cH86SShw0
QGyxHUoKPexCKsAncx5PmqmUuyrtogms/sYRQe43SpWougbCIXVe5mntakGOn/wy
5Gaan5uz2USOxo5kznZFoRVBc9HrJ85IlLDtYY7xH7d0ewHcS7pGqxlNa+9Mys7B
4WwAuU2nPEy+FwifljpW9EHUPTbXDadpQvcjZ0aAqAJIlBJXcZRGt0zO1tfBjjgH
vIHD31jGxghl5XBxzop4LEYUiIfQ6wNdWx11LAkA7/pncJKCdwCO/lqFYjwYHjFi
IeVd75DtvMQJlB6UGUuc
=5c2y
-----END PGP SIGNATURE-----

--SbBsw0IwKtCPQKXuuj06cwhnJshAv23TW--
