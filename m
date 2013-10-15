From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] tcp: remove the sk_can_gso() check from
 tcp_set_skb_tso_segs()
Date: Tue, 15 Oct 2013 12:44:13 -0700
Message-ID: <1381866253.2045.70.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381865094.2045.69.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:56407 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759560Ab3JOToP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 15:44:15 -0400
Received: by mail-pd0-f169.google.com with SMTP id r10so9350821pdi.0
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 12:44:14 -0700 (PDT)
In-Reply-To: <1381865094.2045.69.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-15 at 12:24 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
