From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-08-29
Date: Tue, 29 Aug 2017 09:37:41 -0700 (PDT)
Message-ID: <20170829.093741.419300241043449914.davem@davemloft.net>
References: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751447AbdH2Qhm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 12:37:42 -0400
In-Reply-To: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 29 Aug 2017 12:31:27 +0200

> 1) Fix dst_entry refcount imbalance when using socket policies.
>    From Lorenzo Colitti.
> 
> 2) Fix locking when adding the ESP trailers.
> 
> 3) Fix tailroom calculation for the ESP trailer by using
>    skb_tailroom instead of skb_availroom.
> 
> 4) Fix some info leaks in xfrm_user.
>    From Mathias Krause.
> 
> Please pull or let me know if there are problems.

Pulled, thank you.
