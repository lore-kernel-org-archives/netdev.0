From: Jerry Jiang <wjiang@resilience.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 9 Aug 2007 17:18:32 +0800
Message-ID: <20070809171832.1568864b.wjiang@resilience.com>
References: <8Q2Pg-8uV-23@gated-at.bofh.it>
	<8Q7Fa-7rJ-1@gated-at.bofh.it>
	<8Q8rD-hh-7@gated-at.bofh.it>
	<E1IJ424-0000d7-HK@be1.lrz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Chris Snook <csnook@redhat.com>, akpm@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	cfriesen@nortel.com, zlynx@acm.org
To: 7eggert@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 207.47.19.6.static.nextweb.net ([207.47.19.6]:40334 "EHLO
	ex1.resilience.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934808AbXHIJTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 05:19:25 -0400
In-Reply-To: <E1IJ424-0000d7-HK@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 09 Aug 2007 11:10:16 +0200
Bodo Eggert <7eggert@gmx.de> wrote:

> >=20
> > Why the *volatile-accesses-in-code* is acceptable, does C standard =
make it
> > clear?
>=20
> http://lwn.net/Articles/233482/

I have read this article before, but What Linus said only focusing on
the conclusion-- The semantics of it are so unclear as
to be totally useless.

and still not to said "Why the *volatile-accesses-in-code* is
acceptable"

-- Jerry


> --=20
> Fun things to slip into your budget
> Heisenberg Compensator upgrade kit
>=20
> Fri=C3=9F, Spammer: uWfuXeviZ@x.7eggert.dyndns.org
