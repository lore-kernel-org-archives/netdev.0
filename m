From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp cache
Date: Wed, 15 Mar 2017 17:06:58 -0700
Message-ID: <1489622818.28631.191.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
         <20170315.154044.170788541865531834.davem@davemloft.net>
         <1489618741.28631.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170315.164508.1392215340407263261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: soheil.kdev@gmail.com, netdev@vger.kernel.org, soheil@google.com,
        edumazet@google.com, ncardwell@google.com, ycheng@google.com,
        lvml@5t9.de, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35809 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750977AbdCPAHG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 20:07:06 -0400
Received: by mail-pg0-f68.google.com with SMTP id g2so3866067pge.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 17:07:05 -0700 (PDT)
In-Reply-To: <20170315.164508.1392215340407263261.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-15 at 16:45 -0700, David Miller wrote:

> Ok, I guess we can remove it in that case.  I'm still a bit disappointed
> as I was always hoping someone would find a way to make this work even
> in the presence of NAT.

Nat are good, Nat are good.

I can't find this hilarious video we watched in Copenhagen ;)
