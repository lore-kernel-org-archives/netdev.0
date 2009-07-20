From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: regression: wireless authentication
Date: Mon, 20 Jul 2009 12:29:19 -0400
Message-ID: <20090720162919.GE2775@tuxdriver.com>
References: <1279186756.260191248106587108.JavaMail.root@mail-01.cse.ucsc.edu> <1198385022.260301248106740802.JavaMail.root@mail-01.cse.ucsc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Noah Watkins <jayhawk@soe.ucsc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48937 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbZGTQaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 12:30:55 -0400
Content-Disposition: inline
In-Reply-To: <1198385022.260301248106740802.JavaMail.root@mail-01.cse.ucsc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 20, 2009 at 09:19:00AM -0700, Noah Watkins wrote:
> The latest version I've tried that works fine is Linus' 2.6.31-rc3
> with the latest commit being:
>=20
> commit 35b5c55fee08e6e4001ba98060a2d0b82f70b5f4
> Merge: e9e961c... b2dde6a...
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Wed Jul 15 10:29:09 2009 -0700
>=20
> I encountered the problem I described when I booted:
>=20
> 2.6.31-rc3-next-20090716

That's cool, but it is a bit "apples and oranges"...  What was the
last -next version that was working for you?

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
			=A1Viva Honduras Libre!
