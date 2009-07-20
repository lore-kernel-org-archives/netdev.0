From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] TCP: Add comments to (near) all functions in
	tcp_output.c v2
Date: Mon, 20 Jul 2009 14:34:04 +0200
Message-ID: <20090720123404.GA16072@basil.fritz.box>
References: <20090717204004.GA516@basil.fritz.box> <Pine.LNX.4.64.0907180919270.31457@melkinkari.cs.Helsinki.FI> <20090718103159.GB2682@basil.fritz.box> <4A645DDD.8050402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52997 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbZGTMeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 08:34:09 -0400
Content-Disposition: inline
In-Reply-To: <4A645DDD.8050402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 20, 2009 at 08:06:53PM +0800, Shan Wei wrote:
> Andi Kleen said:
> > =20
> > +/* Compute TCP options for ESTABLISHED sockets. This is not the
> > + * final wire format yet.
> > + */
>=20
> typo, =E2=80=9Cnetwork wire=E2=80=9D?

I don't see a typo.

>=20
>=20
> > +/* Test if sending is allowed right now.
> > + */
> >  int tcp_may_send_now(struct sock *sk)
>=20
> Is it better to provide the condition be allowed?

Such a introductionary comment is not intended to be a full
representation of the code, just a overview.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
