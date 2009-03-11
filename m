From: Riku Voipio <riku.voipio@iki.fi>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 21:15:30 +0200
Message-ID: <20090311191530.GA18211@kos.to>
References: <20090311.014957.117115597.davem@davemloft.net>
	<20090311085721.GV425@pengutronix.de>
	<20090311090938.E7BF7832E8B8@gemini.denx.de>
	<20090311.062336.238430706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0112308856=="
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <20090311.062336.238430706.davem@davemloft.net>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org


--===============0112308856==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="X1bOJ3K7DJ5YkBrT"
Content-Disposition: inline


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 11, 2009 at 06:23:36AM -0700, David Miller wrote:
> That's what NVRAM, CMOS, EEPROM's and other writable long-term
> storage areas are for.

> To be quite honest with you, any ethernet device that doesn't
> have an EEPROM where the chip instance's ethernet address is
> stored is completely broken.

If that is the case, pretty much every SOHO NAS device (running
linux + samba) being sold in your nearest IT shop is completly
broken.

In such machines, typically the mac address is stored in bootloader's
configuration area in NOR/NAND flash.

--=20
"rm -rf" only sounds scary if you don't have backups

--X1bOJ3K7DJ5YkBrT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFJuA3SibPvMsrqrwMRAhkPAJ9yM8GhuV9mW6fBDjJmqCZSmdJudgCgzY+H
1b8Rr302gzSRceM/027rYhc=
=smqv
-----END PGP SIGNATURE-----

--X1bOJ3K7DJ5YkBrT--


--===============0112308856==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
--===============0112308856==--
