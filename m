From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Wed, 08 Sep 2010 06:13:28 +0200
Message-ID: <1283919208.2634.664.camel@edumazet-laptop>
References: <20100907.125947.39192078.davem@davemloft.net>
	 <1283895316.2634.248.camel@edumazet-laptop> <4C86B402.5000205@ans.pl>
	 <20100907.191606.102548977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ole@ans.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61236 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab0IHENe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 00:13:34 -0400
Received: by fxm16 with SMTP id 16so494196fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 21:13:32 -0700 (PDT)
In-Reply-To: <20100907.191606.102548977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 19:16 -0700, David Miller a =C3=A9cri=
t :

> Eric, ipv6 has the same problem so I fixed it there too.
>=20
> Here is the final patch I put into net-2.6, thanks!

Thanks David for taking care of ipv6 too :)


