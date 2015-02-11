From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware
	Unit Hang"
Date: Wed, 11 Feb 2015 03:34:00 -0800
Message-ID: <1423654440.27854.83.camel@jtkirshe-mobl>
References: <1719052.SGOfRAJhfQ@storm>
	<1421333009.11734.53.camel@edumazet-glaptop2.roam.corp.google.com>
	<1421333953.2632.22.camel@jtkirshe-mobl> <2609782.Mryft1leMQ@storm>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1151173374479730073=="
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>, Aaron Brown
	<aaron.f.brown@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <2609782.Mryft1leMQ@storm>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============1151173374479730073==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FTgfxwnBfk4seZM/qyYx"


--=-FTgfxwnBfk4seZM/qyYx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-02-11 at 12:23 +0100, Thomas Jarosch wrote:
> Hi Jeff,
>=20
> On Thursday, 15. January 2015 06:59:13 Jeff Kirsher wrote:
> > > Sure, you basically reverted my patch.
> > >=20
> > > You are not the first to report a problem caused by this patch.
> > >=20
> > > This patch is known to have uncovered some driver bugs.
> > >=20
> > > We are not going to revert it. We are going to fix the real bugs.
> > >=20
> > > Thanks
> >=20
> > Agreed, we are looking into issue Thomas.
>=20
> any news from the Intel labs what might be going on here?
>=20
> We started seeing those hangs on "MSI B85M ECO" boards, too,
> though it's way more sporadic there.

I have not heard anything, so I have added Aaron Brown to see if he has
any additional information.

--=-FTgfxwnBfk4seZM/qyYx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU2z4oAAoJEOVv75VaS+3Or/cP/3mDIMEnRf7cpiNjdChdcuKg
dU9g+J9A6VV+FBWRGsrLxp/4eaM/EAfGZPlVJXdIFI/foLO73gE8SfCHn86XI18D
gpJE8hgV4zttbDJ8mcQmIQ4U9IbDWgbUqqvcDUB8xoih8jTzzmrDGjSUhkmNfFAC
tlFsMhprGdN/lxHnx1Fap7Z98NGrmdYw1Pmx9Wn9oc94gmTV40c+2jkq/LOnR9u5
QrXUM4HrOtVAPr1MLJ2Qed+/fVSwovcI44C4748h4LEamFGTLwLnRPMa5TyzN2Th
zTB60RN44wld+aZnXWxXVZoX/RSsymoUT+WlnrP/JAdUg1mWw1SecIwVwI8ctQZT
GU5Crwe924CY29sznkqFRxpdsZwjR6VZ4WgzY5oA/sTo3cM2iGpSw7eTdN/h37no
QS4kYC5Vnw94Gpcro3YTu0AGfVGFj8QmrcOIM4LF6RxjE533rGAFCzUMUYpSg30C
5x3X/iJ/9iu3W9J8zkHUJri1+XBPqTPHEWahJyvuQXlHMQIHOmHTFzUGfBi2xsll
SgY9SPU3IH0Le0+ruTvbYKic2pP7BYwa2c7fbzSI3pTcKHvCFfMmk5aoadnZZClC
BKc6xCejNXhdotSmWabXV4Gfqp2EZ1oYFAhY/E27eMq/R43Kis8r6No/h+XqH2GS
VVhE78pRf9ji/+jVFl8P
=CxBW
-----END PGP SIGNATURE-----

--=-FTgfxwnBfk4seZM/qyYx--



--===============1151173374479730073==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
--===============1151173374479730073==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============1151173374479730073==--
