From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: make sysctl_tcp_ecn namespace aware
Date: Sat, 05 Jan 2013 18:19:22 -0800
Message-ID: <1357438762.1678.5215.camel@edumazet-glaptop>
References: <20130105150130.GC4031@order.stressinduktion.org>
	 <20130105110005.2bf230eb@nehalam.linuxnetplumber.net>
	 <20130105190508.GE4031@order.stressinduktion.org>
	 <20130106011849.GA28545@order.stressinduktion.org>
	 <1357435646.1678.5082.camel@edumazet-glaptop>
	 <20130106021048.GA32202@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:49378 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975Ab3AFCTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 21:19:25 -0500
Received: by mail-pb0-f48.google.com with SMTP id rq13so9930418pbb.21
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 18:19:24 -0800 (PST)
In-Reply-To: <20130106021048.GA32202@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-06 at 03:10 +0100, Hannes Frederic Sowa wrote:
> As per suggestion from Eric Dumazet this patch makes tcp_ecn sysctl
> namespace aware.  The reason behind this patch is to ease the testing
> of ecn problems on the internet and allows applications to tune their
> own use of ecn.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Seems good to me, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
