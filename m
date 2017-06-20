From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] more skb_put_[data:zero] related work
Date: Tue, 20 Jun 2017 13:30:35 -0400 (EDT)
Message-ID: <20170620.133035.256461429610386187.davem@davemloft.net>
References: <1497796914-25053-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdFTRah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 13:30:37 -0400
In-Reply-To: <1497796914-25053-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Sun, 18 Jun 2017 22:41:54 +0800

> yuan linyu (3):
>   net: introduce __skb_put_[zero, data, u8]
>   net: replace more place to skb_put_[data:zero]
>   net: manual clean code which call skb_put_[data:zero]

Series applied, thanks.
