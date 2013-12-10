From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting permanent mac address
Date: Tue, 10 Dec 2013 17:10:50 +0100
Message-ID: <201312101710.51015@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <1386494714-21070-16-git-send-email-pali.rohar@gmail.com> <87txegpuyk.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5139172.ScLoRPZvaW";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: Kalle Valo <kvalo@adurom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87txegpuyk.fsf@purkki.adurom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5139172.ScLoRPZvaW
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 10 December 2013 16:49:23 Kalle Valo wrote:
> Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:
> > Driver wl1251 generating mac address randomly at startup and
> > there is no way to set permanent mac address via
> > SET_IEEE80211_PERM_ADDR. This patch export sysfs file which
> > can set permanent mac address by userspace helper program.
> > Patch is needed for devices which do not store mac address
> > in internal wl1251 eeprom.
> >=20
> > Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
>=20
> We have ioctl() command for setting the mac address.

Really? Is there ioctl for setting permanent mac address?
Can you show me it?

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart5139172.ScLoRPZvaW
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlKnPQoACgkQi/DJPQPkQ1ID0wCeK8927F0vrMmTB9OXR9P7AGi4
sfoAn1nv5jrhT8VNKmoyC7Ev8fgQ1pLK
=KlEV
-----END PGP SIGNATURE-----

--nextPart5139172.ScLoRPZvaW--
