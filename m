From: Valdis.Kletnieks@vt.edu
Subject: mmotm 2010-10-20 - netfilter Kconfig whinge
Date: Thu, 21 Oct 2010 07:14:45 -0400
Message-ID: <83468.1287659685@localhost>
References: <201010202233.o9KMXNoL008303@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1287659685_4988P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netfilter@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-98-249-9-36.hsd1.va.comcast.net ([98.249.9.36]:59352 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756254Ab0JUL3U (ORCPT
	<RFC822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:29:20 -0400
In-Reply-To: Your message of "Wed, 20 Oct 2010 15:01:43 PDT."
             <201010202233.o9KMXNoL008303@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1287659685_4988P
Content-Type: text/plain; charset="us-ascii"
Content-Id: <83421.1287659675.1@localhost>

On Wed, 20 Oct 2010 15:01:43 PDT, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2010-10-20-15-01 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

Seen during 'make oldconfig':

      Input subsystem LEDs Trigger (LEDS_TRIGGER_INPUT) [N/m/y/?] (NEW) m
      *
      * iptables trigger is under Netfilter config (LED target)
      *
warning: (NETFILTER_XT_MATCH_REALM && NET && INET && NETFILTER && NETFILTER_XTABLES && NETFILTER_ADVANCED || NET_CLS_ROUTE4 && NET && NET_SCHED) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)
#
# configuration written to .config
#




--==_Exmh_1287659685_4988P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFMwCClcC3lWbTT17ARAg7cAJ9oCFBplj1ZieJYUE/KekUlN2EDBQCg/sFO
kGtt3GnuTFCWAtxwO5TZCSE=
=XEit
-----END PGP SIGNATURE-----

--==_Exmh_1287659685_4988P--
