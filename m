From: Noah Watkins <jayhawk@soe.ucsc.edu>
Subject: Re: regression: wireless authentication
Date: Mon, 20 Jul 2009 09:49:00 -0700 (PDT)
Message-ID: <936794064.261051248108540282.JavaMail.root@mail-01.cse.ucsc.edu>
References: <20090720162919.GE2775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-01.cse.ucsc.edu ([128.114.48.32]:50410 "EHLO
	mail-01.cse.ucsc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbZGTQtA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 12:49:00 -0400
In-Reply-To: <20090720162919.GE2775@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yeh, sorry--I forgot to mention I'm just now getting started
with linux-next, so I haven't successfully used wireless with
linux-next. I began to do a bisect and got preempted by the
weekend.

-n

----- Original Message -----
=46rom: "John W. Linville" <linville@tuxdriver.com>
To: "Noah Watkins" <jayhawk@soe.ucsc.edu>
Cc: linux-next@vger.kernel.org, "LKML" <linux-kernel@vger.kernel.org>, =
netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, "Steph=
en Rothwell" <sfr@canb.auug.org.au>
Sent: Monday, July 20, 2009 9:29:19 AM GMT -08:00 US/Canada Pacific
Subject: Re: regression: wireless authentication

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
			=C2=A1Viva Honduras Libre!
