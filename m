From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: ipv6: avoid wraparound for expired lifetimes
Date: Thu, 25 Jun 2009 01:42:32 -0700 (PDT)
Message-ID: <20090625.014232.100502679.davem@davemloft.net>
References: <20090625073943.GO21357@jayr.de>
	<Pine.LNX.4.64.0906251135410.917@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: me@jayr.de, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40651
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752084AbZFYIm1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 04:42:27 -0400
In-Reply-To: <Pine.LNX.4.64.0906251135410.917@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 25 Jun 2009 11:40:19 +0300 (EEST)

> On Thu, 25 Jun 2009, Jens Rosenboom wrote:
>=20
>> the following patch
>> should fix this, at least it did in the test I ran.
>=20
> You must be kidding...

Jens, don't even bother posting patches that fail to
build.

And if you can't get your patches straight, and the
problem is that you're sending something other than
what you actually tested, that's _MUCH_ worse.
