From: "Udo A. Steinberg" <us15@os.inf.tu-dresden.de>
Subject: Re: Linux-2.5.73 + e100
Date: Tue, 24 Jun 2003 22:58:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624225802.3d33d664.us15@os.inf.tu-dresden.de>
References: <20030624162919.09a45dc0.us15@os.inf.tu-dresden.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1"; boundary="=.G8:xgohh/k,Sf/"
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Network Mailing List <linux-net@vger.kernel.org>
In-Reply-To: <20030624162919.09a45dc0.us15@os.inf.tu-dresden.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=.G8:xgohh/k,Sf/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Tue, 24 Jun 2003 16:29:19 +0200 Udo A. Steinberg (UAS) wrote:

UAS> e100: selftest OK.
UAS> irq 9: nobody cared!
UAS> Call Trace:
[...]
UAS> handlers:
UAS> [<c0205f63>] (acpi_irq+0x0/0x16)
UAS> Disabling IRQ #9
UAS> e100: eth0: Intel(R) PRO/100 Network Connection
UAS>   Hardware receive checksums enabled

Andrew Grover from the ACPI team confirmed that this bug is very likely an
ACPI issue, and not related to the e100 driver. So don't worry about it :)

Regards,
-Udo.

--=.G8:xgohh/k,Sf/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.3.1 (GNU/Linux)

iD8DBQE++LtanhRzXSM7nSkRAnX6AJ9lA4E2K4Umzh9Wp65U9SDNfHmSYwCfTtmB
/kvjKAodTNefC3s3K/3Cb84=
=QIh+
-----END PGP SIGNATURE-----

--=.G8:xgohh/k,Sf/--
