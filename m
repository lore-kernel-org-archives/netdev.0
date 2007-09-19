From: Valdis.Kletnieks@vt.edu
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 16:33:32 -0400
Message-ID: <12044.1190234012@turing-police.cc.vt.edu>
References: <46F13E8B.4050309@redhat.com> <p73sl5aveqh.fsf@bingen.suse.de> <46F15305.2030507@redhat.com> <20070919172653.GB18045@one.firstfloor.org> <46F1608E.7060908@redhat.com> <20070919175700.GC18045@one.firstfloor.org> <46F16418.3070706@redhat.com> <20070919183004.GA18707@one.firstfloor.org>
            <46F16CC1.9090302@hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1190234012_23458P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:54130 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbXISUd7 (ORCPT
	<RFC822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 16:33:59 -0400
In-Reply-To: Your message of "Wed, 19 Sep 2007 11:38:57 PDT."
             <46F16CC1.9090302@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1190234012_23458P
Content-Type: text/plain; charset=us-ascii

On Wed, 19 Sep 2007 11:38:57 PDT, Rick Jones said:

> One has to set their way-back machine pretty far back to find the *BSD 
> bits which used 0.0.0.0 as the "all nets, all subnets" (to mis-use a 
> term) broadcast IPv4 address when sending.  Perhaps as far back as the 
> time before HP-UX 7 or SunOS4.  The bit errors in my dimm memory get 
> pretty dense that far back...

That would be BSD4.2 - BSD4.3 went to all-ones, and it *was* quite the
little mess if you had both flavors of boxes on the same subnet at the same
time, it would packet-storm *quite* easily.

--==_Exmh_1190234012_23458P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFG8YeccC3lWbTT17ARAqunAKDITtSZTXc/9Um64aoRyoJbUreskgCaArs7
G7L5Gmde0JIJtWGVSYokWc4=
=Io+b
-----END PGP SIGNATURE-----

--==_Exmh_1190234012_23458P--
