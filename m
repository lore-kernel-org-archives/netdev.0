From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] Documentation: link in networking docs
Date: Sat, 16 Sep 2017 16:28:02 +0200
Message-ID: <20170916142802.GA13664@amd>
References: <20170916114954.GB5459@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
To: kernel list <linux-kernel@vger.kernel.org>,
        Netdev list <netdev@vger.kernel.org>,
        linux-doc@vger.kernel.org, corbet@lwn.net, davem@davemloft.net
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170916114954.GB5459@amd>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Fix link in filter.txt.

Acked-by: Pavel Machek <pavel@ucw.cz>

diff --git a/Documentation/networking/filter.txt b/Documentation/networking=
/filter.txt
index e5e33ba..789b74d 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -45,7 +45,7 @@ in many more places. There's xt_bpf for netfilter, cls_bp=
f in the kernel
 qdisc layer, SECCOMP-BPF (SECure COMPuting [1]), and lots of other places
 such as team driver, PTP code, etc where BPF is being used.
=20
- [1] Documentation/prctl/seccomp_filter.txt
+ [1] Documentation/userspace-api/seccomp_filter.rst
=20
 Original BPF paper:
=20

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlm9NPIACgkQMOfwapXb+vJvgACfa/JUIHdGs3mW3Mx2XxjmFcLd
ZHUAoIRFYxFmbP8r/wlmZ9+xUQwpSXuD
=tydX
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--
