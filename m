From: Valdis.Kletnieks@vt.edu
Subject: Re: [RFC] bridge: STP timer management range checking
Date: Sun, 31 Aug 2008 22:25:30 -0400
Message-ID: <19455.1220235930@turing-police.cc.vt.edu>
References: <fa.wTMiBcGRgw2fBtdHwtX7y0lkc8s@ifi.uio.no> <48975BD3.6040709@shaw.ca> <a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com> <20080807185802.GA16327@electric-eye.fr.zoreil.com> <a08621850808101200n220afd2dve58abe67830b7a4f@mail.gmail.com> <a08621850808110053j5cbf23e6xdf52c9e7440abf19@mail.gmail.com> <a08621850808291848q5660148fx57d576ecfcbfce8@mail.gmail.com> <a08621850808310151o143845h195a8658d02270d9@mail.gmail.com> <20080831100537.6929c51e@extreme>
            <20080831104309.780cc01f@extreme>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1220235929_12805P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Dushan Tcholich <dusanc@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Robert Hancock <hancockr@shaw.ca>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:34944 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbYIACZl (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 22:25:41 -0400
In-Reply-To: Your message of "Sun, 31 Aug 2008 10:43:09 PDT."
             <20080831104309.780cc01f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1220235929_12805P
Content-Type: text/plain; charset=us-ascii

On Sun, 31 Aug 2008 10:43:09 PDT, Stephen Hemminger said:

> Warning: this may cause user backlash since apparently working but standards
>   conforming configurations will get configuration errors that they didn't
>   see before.

Did you mean "apparently working but *non*-standards conforming"?

Other than that, seems to be a sane application of "Be conservative in what you
send".  Our network is some 30K cat-5 ports, 1100 switches, 1300 wireless
access points, and we appreciate it every time somebody makes things more
bulletproof.  And yes, we prefer things to out-and-out *fail* rather than
run in a wonky configuration - hard failures usually get fixed in a few
minutes, wonkiness can drag on for months of mystifying symptoms...


--==_Exmh_1220235929_12805P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFIu1KZcC3lWbTT17ARAmJaAKD+LZ/6wS6BV8FrmwpE/v41tXfNtACfT7+d
7vnicwD7pqOc9q10nWXNz/4=
=uKnV
-----END PGP SIGNATURE-----

--==_Exmh_1220235929_12805P--
