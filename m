From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bonding, GRO and tcp_reordering
Date: Wed, 01 Dec 2010 05:47:06 +0100
Message-ID: <1291178826.2856.434.camel@edumazet-laptop>
References: <20101130135549.GA22688@verge.net.au>
	 <1291131776.21077.27.camel@bwh-desktop>
	 <1291133073.2904.128.camel@edumazet-laptop>
	 <20101201043445.GC3485@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49202 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453Ab0LAErL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 23:47:11 -0500
Received: by wwa36 with SMTP id 36so6928005wwa.1
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 20:47:10 -0800 (PST)
In-Reply-To: <20101201043445.GC3485@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 13:34 +0900, Simon Horman a =C3=
=A9crit :

> I was tweaking those values recently for some latency tuning
> but I didn't think of them in relation to last night's tests.
>=20
> In terms of my measurements, its just benchmarking at this stage.
> So a trade-off between throughput and latency is acceptable, so long
> as I remember to measure what it is.
>=20

I was thinking again this morning about GRO and bonding, and dont know
if it actually works...

Is GRO on on individual eth0/eth1/eth2 you use, or on bonding device
itself ?



