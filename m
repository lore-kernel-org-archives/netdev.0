From: Harald Welte <laforge@netfilter.org>
Subject: When to submit to which list (was Re: [PATCH] netfilter6: Skip
	extension headers when matching icmp6-type)
Date: Fri, 1 Oct 2004 11:02:21 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041001090221.GO1860@sunbeam.de.gnumonks.org>
References: <200409301244.i8UCid17009482@toshiba.co.jp>
	<415C1CC9.2090604@trash.net>
	<200410010019.i910JlZY002193@toshiba.co.jp>
	<200410010509.i9159Cg2021037@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/T+UM55GOh1Yge7W"
Cc: okir@suse.de, netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	usagi-core@linux-ipv6.org, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Content-Disposition: inline
In-Reply-To: <200410010509.i9159Cg2021037@toshiba.co.jp>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--/T+UM55GOh1Yge7W
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 01, 2004 at 02:09:10PM +0900, Yasuyuki Kozakai wrote:
> # Sometimes I confuse I should send patches to netdev, or send them to
> # netfilter-devel and core team of netfilter review/send it to netdev.

I don't know what Patrick told you, but I think as a general rule of
thumb, all netfilter-related patches should go to netfilter-devel first.
Patrick or I will then push them upstream to DaveM (most times with Cc
to netdev).

For urgent/critical bugfixes (that are not too complex), I am ok if
netfilter-devel is bypassed and you submit it to netdev/davem
immediately.

Pragmatically speaking, Patrick or me will read your emails on either
list - but a number of other netfilter developers is not following
netdev, so you deprive them of the chance to give comments before it is
submitted ;)

Thanks!

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--/T+UM55GOh1Yge7W
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBXR0dXaXGVTD0i/8RAlTsAJ9kMxhFyec9cXf20Z7dH4U+HotAlgCePMol
Fs2rfgLUkx5j3K3s7G1oDbQ=
=ng6f
-----END PGP SIGNATURE-----

--/T+UM55GOh1Yge7W--
