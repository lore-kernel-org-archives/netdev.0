From: Paul TBBle Hampson <Paul.Hampson@Pobox.com>
Subject: Re: [PATCH]: bcm43xx-d80211: fix hwcrypto issues (mcast)
Date: Sat, 18 Nov 2006 12:15:08 +1100
Message-ID: <20061118011508.GB15603@keitarou>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de> <20061114142959.GA17486@keitarou> <200611161507.33971.mb@bu3sch.de> <1163749589.5826.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6sX45UoQRIJXqkqR"
Cc: Michael Buesch <mb@bu3sch.de>, linville@tuxdriver.com,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from betty.cbit.net.au ([202.55.154.10]:61160 "EHLO mail.cbit.net.au")
	by vger.kernel.org with ESMTP id S1753753AbWKRBMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 20:12:39 -0500
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <1163749589.5826.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 17, 2006 at 06:46:29PM +1100, Benjamin Herrenschmidt wrote:
> On Thu, 2006-11-16 at 15:07 +0100, Michael Buesch wrote:
>> This fixes various bcm43xx-d80211 hwcrypto issues,
>> which mainly prevented mcast frames from being decrypted properly.
>>=20
>> This is mostly a rewrite of the key managing code.
>> Note that after this patch v3 firmware is no longer supported.

> So what is the solution for Apple machines owner who only get a v3
> firmware from Apple ? I remember you telling me the answer on irc but I
> wanted to make it public :-) Some web site we can d/l the windows
> updates and extract the FW ?

http://bcm43xx.spugna.org/index.php?topic=3D141.msg517 provides the
following links to 4.80.46.0:

http://www.i-nz.net/files/perm/AppleAirPortBrcm4311.tar.gz
http://www.i-nz.net/files/perm/bcmwl5-win32.tar.gz

--=20
-----------------------------------------------------------
Paul "TBBle" Hampson, B.Sc, LPI, MCSE
On-hiatus Asian Studies student, ANU
The Boss, Bubblesworth Pty Ltd (ABN: 51 095 284 361)
Paul.Hampson@Pobox.Com

Of course Pacman didn't influence us as kids. If it did,
we'd be running around in darkened rooms, popping pills and
listening to repetitive music.
 -- Kristian Wilson, Nintendo, Inc, 1989

License: http://creativecommons.org/licenses/by/2.1/au/
-----------------------------------------------------------

--6sX45UoQRIJXqkqR
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFXl6cexDuohKLFuARAl4fAJ9oZDzGV18dXJh2kiLsjt61JOjX8ACeIygv
8L/D61blX32QZiraGCKECwM=
=Tg3i
-----END PGP SIGNATURE-----

--6sX45UoQRIJXqkqR--
