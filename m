From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Thu, 27 Nov 2014 16:24:03 +0100
Message-ID: <201411271624.03066@pali>
References: <201411271506.20457@pali> <201411271543.23527@pali> <20141127151448.GA23064@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4431700.b8ZnNuNqdA";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pavel Machek <pavel@ucw.cz>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141127151448.GA23064@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4431700.b8ZnNuNqdA
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Thursday 27 November 2014 16:14:48 Greg Kroah-Hartman wrote:
> On Thu, Nov 27, 2014 at 03:43:23PM +0100, Pali Roh=C3=A1r wrote:
> > Which userspace helper programs for (automatic) firmware
> > loading are used? Can be udev configured to use own program
> > for loading firmware instead that udev integrated which
> > looking for firmware only in /lib/firmware files?
>=20
> The code to load firmware from userspace has been removed from
> udev, so that's not going to work at all, sorry.
>=20
> greg k-h

Ok and how to load (dynamic) firmware files into kernel? What is=20
preferred way if not udev (because it removed that support)?

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart4431700.b8ZnNuNqdA
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlR3QhMACgkQi/DJPQPkQ1JPnACfYp6uZ0qB3aSoncyURWxxRCMj
WQUAnRzu75eK2uZQA/O19naSrEv1ESQp
=dAlO
-----END PGP SIGNATURE-----

--nextPart4431700.b8ZnNuNqdA--
