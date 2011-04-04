From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler
Date: Mon, 04 Apr 2011 18:34:00 +0200
Message-ID: <1301934840.3142.23.camel@edumazet-laptop>
References: <20110404083058.2f2be9f1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63492 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab1DDQeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 12:34:07 -0400
Received: by wwa36 with SMTP id 36so6668061wwa.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 09:34:05 -0700 (PDT)
In-Reply-To: <20110404083058.2f2be9f1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 avril 2011 =C3=A0 08:30 -0700, Stephen Hemminger a =C3=A9cr=
it :
> This is an implementation of the Quick Fair Queue scheduler developed
> by Fabio Checconi. The same algorithm is already implemented in ipfw
> in FreeBSD. Fabio had an earlier version developed on Linux, I just
> cleaned it up.  Thanks to Eric Dumazet for testing this under load.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> v6.1 - add one more printk on error path

Tested again this last version on net-next-2.6 and it seems fine.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>



