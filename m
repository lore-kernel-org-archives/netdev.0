From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Tue, 9 Dec 2014 00:27:46 +0100
Message-ID: <201412090027.46485@pali>
References: <201411271506.20457@pali> <201412081747.30965@pali> <20141208205721.GA14895@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2457874.dXyCdr0QfX";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141208205721.GA14895@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2457874.dXyCdr0QfX
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 08 December 2014 21:57:21 Greg Kroah-Hartman wrote:
> Use your own custom usermode helper for stuff like this, not
> the firmware interface.  But use a binary sysfs file if you
> want, that seems to make sense for it...
>=20
> greg k-h

Patch for telling permanent mac address from userspace via sysfs=20
file was rejected for inclusion into mainline kernel.

So I do not think that now maintainers of network subsystem allow=20
it for nvs data...

https://lkml.org/lkml/2013/12/8/35

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart2457874.dXyCdr0QfX
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlSGM/IACgkQi/DJPQPkQ1KNvwCfRf56KOnmL0C2Cvjpu/NLHJu2
94QAn1ZupkdOsiVp9JCu1l9gpw45C43F
=vsxa
-----END PGP SIGNATURE-----

--nextPart2457874.dXyCdr0QfX--
