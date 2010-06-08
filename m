From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] pkt_sched: gen_estimator: kill
 est_lock rwlock
Date: Tue, 08 Jun 2010 14:27:32 +0200
Message-ID: <1276000052.2475.307.camel@edumazet-laptop>
References: <20100608121546.GA9392@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51236 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972Ab0FHM1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 08:27:37 -0400
Received: by wyi11 with SMTP id 11so3146260wyi.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 05:27:35 -0700 (PDT)
In-Reply-To: <20100608121546.GA9392@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 juin 2010 =C3=A0 12:15 +0000, Jarek Poplawski a =C3=A9crit =
:

>=20
> Actually, I guess, Changli meant the bug introduced by your previous
> patch by removing the est_lock. With this lock (and your commit 5d944=
)
> bstats (and API) seem "fundamentaly" safe.
>=20

Sorry, I have no idea of what you want to say, I cant find commit 5d944=
=2E



