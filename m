From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.24-rc6-mm1 - oddness with IPv4/v6 mapped sockets hanging...
Date: Mon, 14 Jan 2008 13:22:10 -0500
Message-ID: <32065.1200334930@turing-police.cc.vt.edu>
References: <30887.1200209733@turing-police.cc.vt.edu> <7197.1200327338@turing-police.cc.vt.edu> <200801141136.41140.paul.moore@hp.com>
            <31130.1200333948@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1200334930_3045P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:48991 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbYANSWs (ORCPT
	<RFC822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 13:22:48 -0500
In-Reply-To: Your message of "Mon, 14 Jan 2008 13:05:48 EST."
             <31130.1200333948@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1200334930_3045P
Content-Type: text/plain; charset=us-ascii

On Mon, 14 Jan 2008 13:05:48 EST, Valdis.Kletnieks@vt.edu said:

> I'm pulling  git://git.infradead.org/users/pcmoore/lblnet-2.6_testing at the
> moment, and seeing if there's already a fix in there for this.

Apparently the only new commit in there since the tree that was in
24-rc6-mm1 is 5d95575903fd3865b884952bd93c339d48725c33 adding some warning
printk's.  Would it be more productive to test against the full tree, or
leaving out the one commit I already reverted?

--==_Exmh_1200334930_3045P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHi6hScC3lWbTT17ARAk+XAJ9C6qfY2fmtxxA5cBaw1tEqP4mxtwCg9ziS
B0RA542l+7+gWHu3pXui2k0=
=SabW
-----END PGP SIGNATURE-----

--==_Exmh_1200334930_3045P--
