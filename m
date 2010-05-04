From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-next: remove useless union keyword
Date: Tue, 04 May 2010 07:07:05 +0200
Message-ID: <1272949625.2407.177.camel@edumazet-laptop>
References: <1272942254-14760-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:59486 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab0EDFHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 01:07:16 -0400
Received: by bwz9 with SMTP id 9so1862401bwz.29
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 22:07:14 -0700 (PDT)
In-Reply-To: <1272942254-14760-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 mai 2010 =C3=A0 11:04 +0800, Changli Gao a =C3=A9crit :
> remove useless union keyword in rtable, rt6_info and dn_route.
>=20
> Since there is only one member in a union, the union keyword isn't us=
eful.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll respin my dst patch


