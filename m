From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
	bitmap_find_next_zero_area
Date: Wed, 14 Oct 2009 08:54:47 +1100
Message-ID: <1255470887.21871.2.camel@concordia>
References: <1255076961-21325-1-git-send-email-akinobu.mita@gmail.com>
	<1255076961-21325-2-git-send-email-akinobu.mita@gmail.com>
	<20091009164100.85a36188.akpm@linux-foundation.org>
	<20091013021818.GA3898@localhost.localdomain>
	<20091013091017.GA18431@localhost.localdomain>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6464853117476823360=="
Cc: Fenghua Yu <fenghua.yu@intel.com>, x86@kernel.org,
	linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, linux-altix@sgi.com,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linuxppc-dev@ozlabs.org, Tony Luck <tony.luck@intel.com>,
	Paul Mackerras <paulus@samba.org>,
	"H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-usb@vger.kernel.org, Ingo Molnar <mingo@redhat.com>,
	Lothar Wassmann <LW@KARO-electronics.de>
To: Akinobu Mita <akinobu.mita@gmail.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20091013091017.GA18431@localhost.localdomain>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


--===============6464853117476823360==
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-qc5/2QIIQzGbB3R6aIJb"


--=-qc5/2QIIQzGbB3R6aIJb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-10-13 at 18:10 +0900, Akinobu Mita wrote:
> My user space testing exposed off-by-one error find_next_zero_area
> in iommu-helper.

Why not merge those tests into the kernel as a configurable boot-time
self-test?

cheers

--=-qc5/2QIIQzGbB3R6aIJb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkrU9ycACgkQdSjSd0sB4dIXTACgpxW+LkFXep2w0my10iBFI6i2
V8MAoL7CL/p4hU/ZoKeP4Luo4ZBAcbef
=En+T
-----END PGP SIGNATURE-----

--=-qc5/2QIIQzGbB3R6aIJb--


--===============6464853117476823360==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============6464853117476823360==--
