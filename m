From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: broadcast addr should be part of
 mc_filter
Date: Fri, 08 Feb 2013 17:57:27 -0500 (EST)
Message-ID: <20130208.175727.39793523456548806.davem@davemloft.net>
References: <1360288977.28557.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, maze@google.com
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947164Ab3BHW52 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 17:57:28 -0500
In-Reply-To: <1360288977.28557.77.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <erdnetdev@gmail.com>
Date: Thu, 07 Feb 2013 18:02:57 -0800

> From: Eric Dumazet <edumazet@google.com>
>=20
> commit cd431e738509e (macvlan: add multicast filter) forgot
> the broadcast case.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Maciej =AFenczykowski <maze@google.com>

Applied.
