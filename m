From: "Stefan (metze) Metzmacher" <metze@samba.org>
Subject: Re: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm:
 mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Wed, 01 Jun 2011 13:54:37 +0200
Message-ID: <4DE6287D.5080807@samba.org>
References: <1306922913-17803-1-git-send-email-metze@samba.org> <1306922913-17803-2-git-send-email-metze@samba.org> <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local> <4DE618B7.5070903@samba.org> <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E64B@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig721BDC27E8EC36BD4552E18E"
Cc: Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E64B@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig721BDC27E8EC36BD4552E18E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 01.06.2011 13:39, schrieb Alexey ORISHKO:
>> -----Original Message-----
>> From: Stefan (metze) Metzmacher [mailto:metze@samba.org]
>> Sent: Wednesday, June 01, 2011 12:47 PM
>>
>> Would it be possible to add some autodetection for known devices, in a=

>> similar way the cdc_ether driver does it.
>=20
> If you use udev rules and create an alias for your device, you won't
> be dependent on generic driver code.

Ok, do you have examples for that?

metze


--------------enig721BDC27E8EC36BD4552E18E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3mKH0ACgkQm70gjA5TCD8BWQCcCnVwO2wA0cxUAfVreyDHPllu
xHYAn1sXDMf9T2yiQYYOQt8twiPwZEX9
=YuV9
-----END PGP SIGNATURE-----

--------------enig721BDC27E8EC36BD4552E18E--
