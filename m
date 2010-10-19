From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3 v2] net: fail alloc_netdev_mq if queue count < 1
Date: Tue, 19 Oct 2010 07:02:34 +0200
Message-ID: <1287464554.2305.0.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1010182053060.6676@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49929 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab0JSFCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 01:02:39 -0400
Received: by wyb28 with SMTP id 28so2081248wyb.19
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 22:02:37 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1010182053060.6676@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 18 octobre 2010 =C3=A0 20:55 -0700, Tom Herbert a =C3=A9crit :
> In alloc_netdev_mq fail if requested queue_count < 1.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/dev.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


