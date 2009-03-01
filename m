From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2009-02-27-13-54 uploaded
Date: Sat, 28 Feb 2009 22:13:27 -0500
Message-ID: <16888.1235877207@turing-police.cc.vt.edu>
References: <200902272212.n1RMClcN007585@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1235877207_4195P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: mm-commits@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:51774 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755276AbZCADNe (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 22:13:34 -0500
In-Reply-To: Your message of "Fri, 27 Feb 2009 13:55:15 PST."
             <200902272212.n1RMClcN007585@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1235877207_4195P
Content-Type: text/plain; charset=us-ascii

On Fri, 27 Feb 2009 13:55:15 PST, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2009-02-27-13-54 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

Something in (apparently) linux-next.patch is breaking networking big time
on my laptop - iptables and ip6tables won't initialize, interfaces won't
ifconfig up.  Doing some digging backwards, the problem hit sometime between
mmotm-0129 and mmotm-0214.

Wish I could be more specific - I've been too busy with other stuff this
month to test more -mm kernels and narrow down the problem. Any suggestions?

--==_Exmh_1235877207_4195P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJqf1WcC3lWbTT17ARAr6ZAJwKehTwkjmGWaLpzSlxpcMOEtefVwCfelhE
bWzDLt4UsFCmDf0CS4+O04o=
=JMks
-----END PGP SIGNATURE-----

--==_Exmh_1235877207_4195P--
