From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Wed, 02 Mar 2011 17:18:48 +0100
Message-ID: <1299082728.2920.18.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <20110302020610.GD1005@gandalf.sssup.it>
	 <1299064667.2920.4.camel@edumazet-laptop> <20110302081108.689571d8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Checconi <fchecconi@gmail.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34570 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436Ab1CBQbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 11:31:12 -0500
Received: by mail-ey0-f174.google.com with SMTP id 24so39719eyx.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 08:31:12 -0800 (PST)
In-Reply-To: <20110302081108.689571d8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 08:11 -0800, Stephen Hemminger a =C3=A9=
crit :

> I put the iproute2 code into the repository in the experimental branc=
h.
>=20

Thanks

It seems as soon as packets are dropped, qdisc is frozen (no more
packets dequeued)

Hmm...



