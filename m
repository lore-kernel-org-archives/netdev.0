From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: trying to track a change to drivers/isdn/usb-gigaset.c
Date: Mon, 07 May 2007 18:23:23 +0200
Message-ID: <463F527B.4030509@imap.cc>
References: <463EF77A.9020808@imap.cc> <20070507.034117.115910272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4F3726D7F8EC3654B4594E34"
Cc: linux-kernel@vger.kernel.org, acme@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965714AbXEGQXe@vger.kernel.org>
In-Reply-To: <20070507.034117.115910272.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4F3726D7F8EC3654B4594E34
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David Miller schrieb:
> [ netdev@vger.kernel.org is the place to discuss kernel networking
>   issues, thanks ]

OIC. My bad. I didn't make the connection from "skb" to "networking". Sor=
ry.

> It was a change done so that we could hide the skb data buffering
> details to the point where we could change the protocol header
> pointers into 32-bit offsets which saves 4 bytes per such pointer per
> protocol header stored in struct sk_buff.

Thanks for the explanation.

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig4F3726D7F8EC3654B4594E34
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGP1J7MdB4Whm86/kRAhFVAJoDavWzJI0JB/25462KFZRP/RT9VgCcDQ+1
brkVMCEPOahm/JDaa3nut3Y=
=dyoQ
-----END PGP SIGNATURE-----

--------------enig4F3726D7F8EC3654B4594E34--
