From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] flow_dissector: remove unused functions
Date: Wed, 02 Aug 2017 10:50:31 -0700 (PDT)
Message-ID: <20170802.105031.841133489228992304.davem@davemloft.net>
References: <20170801201809.12922-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdHBRud (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 13:50:33 -0400
In-Reply-To: <20170801201809.12922-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  1 Aug 2017 13:18:09 -0700

> They are introduced by commit f70ea018da06
> ("net: Add functions to get skb->hash based on flow structures")
> but never gets used in tree.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Yeah these can be reintroduced if we really end up needing them.

Applied, thanks.
