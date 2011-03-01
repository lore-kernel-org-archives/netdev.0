From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Tue, 01 Mar 2011 06:28:41 +0100
Message-ID: <1298957321.2676.6.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64078 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515Ab1CAF2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 00:28:46 -0500
Received: by wyg36 with SMTP id 36so4345918wyg.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 21:28:45 -0800 (PST)
In-Reply-To: <20110228171738.2cc8c9a0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 17:17 -0800, Stephen Hemminger a =C3=
=A9crit :
> This is an implementation of the Quick Fair Queue scheduler developed
> by Fabio Checconi. The same algorithm is already implemented in ipfw
> in FreeBSD. Fabio had an earlier version developed on Linux, I just
> cleaned it up and tested it. All bugs are mine.
>=20
> This version is still experimental, do not use for production.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Seems very complex stuff ;)

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll perform some tests today with QFQ, thanks !



