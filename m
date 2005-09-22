From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 3/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 14:50:04 +0200
Message-ID: <20050922125004.GI26520@sunbeam.de.gnumonks.org>
References: <432EF0C5.5090908@cosmosbay.com> <200509191948.55333.ak@suse.de>
	<432FDAC5.3040801@cosmosbay.com> <200509201830.20689.ak@suse.de>
	<433082DE.3060308@cosmosbay.com> <43308324.70403@cosmosbay.com>
	<4331D290.6070104@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZPDwMsyfds7q4mrK"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <4331D290.6070104@cosmosbay.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--ZPDwMsyfds7q4mrK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 21, 2005 at 11:37:20PM +0200, Eric Dumazet wrote:
> Patch 3/3 (please apply after Patch 2/3)

Thanks for your patches, again.

> 3) NUMA allocation.

I'll wait with applying this patch until a decision has been made on
merging something like vmalloc_node() to mainline.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--ZPDwMsyfds7q4mrK
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDMqh8XaXGVTD0i/8RAq6dAJ9WGu576KG8KrPLA3gVYszkO4nxhwCcDMUO
aWNzxgyOy2Ym6vE/LuReTOo=
=Us/a
-----END PGP SIGNATURE-----

--ZPDwMsyfds7q4mrK--
