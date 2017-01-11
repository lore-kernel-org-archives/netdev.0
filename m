From: David Miller <davem@davemloft.net>
Subject: Re: 4.9.2 panic, __skb_flow_dissect, gro?
Date: Tue, 10 Jan 2017 20:08:04 -0500 (EST)
Message-ID: <20170110.200804.303728442314129894.davem@davemloft.net>
References: <359da98eb44a5a9f9f286cc380143654@nuclearcat.com>
        <96694297c5f7178b92bfd9a12bef4a42@nuclearcat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.kumlien@gmail.com
To: nuclearcat@nuclearcat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33360 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758096AbdAKBII (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:08:08 -0500
In-Reply-To: <96694297c5f7178b92bfd9a12bef4a42@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Date: Wed, 11 Jan 2017 01:49:34 +0200

> It seems this patch solve issue. I hope it will go to stable asap,
> because without it loaded routers crashing almost instantly on 4.9.

I will submit this soon.
