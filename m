From: Simon Horman <horms@verge.net.au>
Subject: Re: Bonding, GRO and tcp_reordering
Date: Thu, 2 Dec 2010 15:39:41 +0900
Message-ID: <20101202063939.GA30021@verge.net.au>
References: <20101130135549.GA22688@verge.net.au>
 <1291131776.21077.27.camel@bwh-desktop>
 <1291133073.2904.128.camel@edumazet-laptop>
 <20101201043445.GC3485@verge.net.au>
 <1291178826.2856.434.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43268 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869Ab0LBGjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 01:39:46 -0500
Content-Disposition: inline
In-Reply-To: <1291178826.2856.434.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 01, 2010 at 05:47:06AM +0100, Eric Dumazet wrote:
> Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 13:34 +0900, Simon Horman a =
=C3=A9crit :
>=20
> > I was tweaking those values recently for some latency tuning
> > but I didn't think of them in relation to last night's tests.
> >=20
> > In terms of my measurements, its just benchmarking at this stage.
> > So a trade-off between throughput and latency is acceptable, so lon=
g
> > as I remember to measure what it is.
> >=20
>=20
> I was thinking again this morning about GRO and bonding, and dont kno=
w
> if it actually works...
>=20
> Is GRO on on individual eth0/eth1/eth2 you use, or on bonding device
> itself ?

All of the above. I can check different combinations if it helps.

