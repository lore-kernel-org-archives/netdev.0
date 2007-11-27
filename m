From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 15:02:02 -0500
Message-ID: <25135.1196193722@turing-police.cc.vt.edu>
References: <20071127105016.GC24223@one.firstfloor.org> <E1Ix0ws-0001Vh-00@gondolin.me.apana.org.au>
            <20071127141242.GA26794@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1196193722_2895P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, rusty@rustcorp.com.au,
	rdreier@cisco.com, ak@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:48367 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301AbXK0UC3 (ORCPT
	<RFC822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 15:02:29 -0500
In-Reply-To: Your message of "Tue, 27 Nov 2007 15:12:42 +0100."
             <20071127141242.GA26794@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1196193722_2895P
Content-Type: text/plain; charset=us-ascii

On Tue, 27 Nov 2007 15:12:42 +0100, Andi Kleen said:
> > OK, short of making IPv4 a module (which would be a worthy task :)
> 
> At some point there were patches, it is probably not very difficult.
> But DaveM resisted at some point because he didn't want people
> to replace the network stack (although I personally don't have a problem
> with that)

Personally, I wouldn't find replacing the ipv4 stack very interesting.

However, stress-testing your system for IPv6-readiness by doing 'rmmod ipv4' :)

(Though I admit it's something I'd *try* if it was available, but certainly
not sufficient for a reason to do it...)

--==_Exmh_1196193722_2895P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHTHe6cC3lWbTT17ARAqC+AKCUaFpZwEcazQf9SQoYtbqj9HkMgACfciGH
GTMCV/7UEQ4toPTbBN10R2A=
=+kwr
-----END PGP SIGNATURE-----

--==_Exmh_1196193722_2895P--
