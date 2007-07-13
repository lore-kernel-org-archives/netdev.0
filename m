From: Valdis.Kletnieks@vt.edu
Subject: Re: Re: [2.6.23 PATCH 13/18] dm: netlink
Date: Fri, 13 Jul 2007 16:12:58 -0400
Message-ID: <6408.1184357578@turing-police.cc.vt.edu>
References: <20070711210137.GE24114@agk.fab.redhat.com>
	<20070711142712.e646995b.akpm@linux-foundation.org>
	<20070712231920.GZ11166@waste.org>
	<20070712163115.ee686f8d.akpm@linux-foundation.org>
	<20070713020059.GA5402@us.ibm.com>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1246049560=="
Cc: netdev@vger.kernel.org,
	device-mapper development <dm-devel@redhat.com>,
	linux-kernel@vger.kernel.org, Alasdair G Kergon <agk@redhat.com>,
	Matt Mackall <mpm@selenic.com>
To: Mike Anderson <andmike@us.ibm.com>
Return-path: <dm-devel-bounces@redhat.com>
In-Reply-To: Your message of "Thu, 12 Jul 2007 19:00:59 PDT."
	<20070713020059.GA5402@us.ibm.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

--===============1246049560==
Content-Type: multipart/signed; boundary="==_Exmh_1184357578_3376P";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit

--==_Exmh_1184357578_3376P
Content-Type: text/plain; charset=us-ascii

On Thu, 12 Jul 2007 19:00:59 PDT, Mike Anderson said:

> No, all admin tools and interfaces function as they do today. The
> dm-netlink patch series only contains 9 deletions (actual just one true
> deletion of existing kernel code the others are due to break up of the
> patch into compilable chunks). The intent was not to break users or force
> migration.

OK, I'll bite - if the admin tools function as before, who is *using* the
code?  Or do the admin tools have a preferred netlink component and a fallback
set of code if that fails?

--==_Exmh_1184357578_3376P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGl9zKcC3lWbTT17ARAn1TAJwK7uClY988U38VvooewVlui/+RpwCg3cJr
DTxUbQjXfXFwFebgArnL3KM=
=DJ4I
-----END PGP SIGNATURE-----

--==_Exmh_1184357578_3376P--


--===============1246049560==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1246049560==--
