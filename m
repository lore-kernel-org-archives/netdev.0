From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] [IPV6] cleanup: remove unused IPV6 stats
 entries.
Date: Tue, 18 Oct 2011 08:44:46 +0200
Message-ID: <1318920286.2571.49.camel@edumazet-laptop>
References: <CAGXs5wVxkqLeCEMV6Lanczj-zarv6iu4ekdjk5zZKaadabwvbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55078 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668Ab1JRGoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 02:44:55 -0400
Received: by wwe6 with SMTP id 6so402397wwe.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 23:44:54 -0700 (PDT)
In-Reply-To: <CAGXs5wVxkqLeCEMV6Lanczj-zarv6iu4ekdjk5zZKaadabwvbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 07:36 +0200, Kevin Wilson a =C3=A9crit =
:
> Hi,
>=20
> This cleanup patch removes three unused IPV6 stats entries
> from rt6_statistics struct. (ip6_fib.h).
>=20
> Regards,
>   wkevils@gmail.com
>=20
>=20
> Signed-off-by: Kevin Wilson <wkevils@gmail.com>

Hi Kevin

Did you change all /proc/net/rt6_stats users so that they still continu=
e
to work, including closed source ones ?
