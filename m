From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] net: use skb_cow_head() to deal with cloned
 skbs
Date: Fri, 21 Apr 2017 13:25:47 -0400 (EDT)
Message-ID: <20170421.132547.50479754277089331.davem@davemloft.net>
References: <20170419165926.30631-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, james.hughes@raspberrypi.org,
        eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35934 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423197AbdDUSCc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:02:32 -0400
In-Reply-To: <20170419165926.30631-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 19 Apr 2017 09:59:20 -0700

> James Hughes found an issue with smsc95xx driver. Same problematic code
> is found in other drivers.

Series applied, thanks Eric.
