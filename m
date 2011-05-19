From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4] rps: Infrastructure in __skb_get_rxhash for deep
 inspection
Date: Thu, 19 May 2011 22:27:37 +0200
Message-ID: <1305836857.3156.22.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1105190828001.12835@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47387 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933727Ab1ESU1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:27:41 -0400
Received: by wwa36 with SMTP id 36so3292755wwa.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 13:27:40 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105190828001.12835@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 08:39 -0700, Tom Herbert a =C3=A9crit :
> Basics for looking for ports in encapsulated packets in tunnels.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/dev.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
>=20

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>



