From: David Miller <davem@davemloft.net>
Subject: Re: Treason uncloaked / Broken peer again
Date: Fri, 27 Feb 2009 16:31:05 -0800 (PST)
Message-ID: <20090227.163105.240371624.davem@davemloft.net>
References: <20090226085826.GA12498@gondor.apana.org.au>
	<Pine.LNX.4.64.0902261105030.31742@wrl-59.cs.helsinki.fi>
	<20090227212234.GB25573@bx9.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: greg@blekko.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47311
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752708AbZB1AbY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 19:31:24 -0500
In-Reply-To: <20090227212234.GB25573@bx9.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Greg Lindahl <greg@blekko.com>
Date: Fri, 27 Feb 2009 13:22:34 -0800

> On Thu, Feb 26, 2009 at 11:30:58AM +0200, Ilpo J=E4rvinen wrote:
>=20
> > Right, it's rather crude to have buggy kernel which sends past the=20
> > receiver's advertized window, and then when it cannot cope the resu=
lts of=20
> > its own bug (and prints that message), put a blame on others who be=
have in=20
> > a compliant way.
>=20
> Well, perhaps we shouldn't have the message be "Broken peer" when the
> problem is often on the node printing the message? Maybe "Something's
> broken, might be me"?

As has been mentioned several times in this thread and others, we have
tweaked the message to be more reasonable and in particular it doesn't
say "broken peer" any more.
