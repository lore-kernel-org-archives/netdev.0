From: Sven Eckelmann <sven@narfation.org>
Subject: Re: Re: [B.A.T.M.A.N.] pull request: batman-adv 2012-02-17
Date: Fri, 17 Feb 2012 21:44:19 +0100
Message-ID: <1990573.JisbTKXt7B@sven-laptop.home.narfation.org>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de> <20120217.152323.2251437927591117547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart14305007.jMuiF02TAd"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, lindner_marek@yahoo.de,
	netdev@vger.kernel.org
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:46140 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120Ab2BQUo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 15:44:29 -0500
In-Reply-To: <20120217.152323.2251437927591117547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart14305007.jMuiF02TAd
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Friday 17 February 2012 15:23:23 David Miller wrote:
> From: Marek Lindner <lindner_marek@yahoo.de>
> Date: Fri, 17 Feb 2012 15:18:20 +0800
> 
> > The following changes since commit 
dcd6c92267155e70a94b3927bce681ce74b80d1f:
> >   Linux 3.3-rc1 (2012-01-19 15:04:48 -0800)
> > 
> > are available in the git repository at:
> >   git://git.open-mesh.org/linux-merge.git batman-adv-for-davem
> 
> Somethings up:
> 
> [davem@drr net-next]$ git pull git://git.open-mesh.org/linux-merge.git
> batman-adv-for-davem fatal: Couldn't find remote ref batman-adv-for-davem
> 
> which is strange because I can see the tag there on git.open-mesh.org when
> I check it with my web browser.

Just tried it here (used linux-next for that) with git 1.7.9 and it worked 
fine. Maybe you are using an older version of git? At least the error message 
looks like it.

Have you tried:

 git pull git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

But this will drop Mareks signature when done with an old git version (so no 
merged tag is created).

Kind regards,
	Sven
--nextPart14305007.jMuiF02TAd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPPrwjAAoJEF2HCgfBJntG+NIQAIwaA2Yu2rkWEOSU9VoyIjKd
70j6ZxxNq0oIy8ygyzLFu9xD5IADkiQA9rR/ToegINyLv3wZP2KTTIoHHyUk12uq
lppxf9PfvPY5RZPzDQbkPv/TyKOQfJMdODEUIe1NYRsoTndr974IKvY5kXgJdBM8
U6yO59JBiTVfos0dkSz6Hb6ZigfkoNbDAoyEkfn61tbQJubBOya/me71apRtIveW
lF9UIv95L5x7Rzgwc0MVxufcWpqmLanQx+oaDMxZmRkMHt1pg5etoVA+ZQhhX+Ac
+KXZzden5eH56kiTSf/io63Wgq41awnmDUmk+K5pDHAGMRIULvp1efyPYhCDhDqw
2iARvTq0FS0rQt1N3tOeOe7gptfcxkTL0F6AunyKfRccDx8d08mwGVurFUWGbFOI
wkWi/3xdyP4KCUL3cVRLlR6sPT9/txzl4QT2PlJmhm0pHvjC7v/jXKivOTCJGHYa
tvnbn/vA+UFLJTXAgfLZ4RncMfBQjci0twPbhoe0gy6jcKp+qyJzzT856Rw10aZp
bxFJ8vRqptzhoW+X7w2QjULj4AOaVmy5XGBRdDgGK9wWwgKFEOWn4ty110iqjIjd
wESTqCW1tJCyoizsj5aqZ3a16zkRb+sfiLsbqM7OO0Me02Gw19ZaFTeEhsfHYwAQ
3CTxJYs7dh5OToH9hNXo
=n+hX
-----END PGP SIGNATURE-----

--nextPart14305007.jMuiF02TAd--
