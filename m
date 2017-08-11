From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_needs_check() removes
 CHECKSUM_UNNECESSARY check for tx.
Date: Fri, 11 Aug 2017 14:46:09 -0700 (PDT)
Message-ID: <20170811.144609.135901458013653513.davem@davemloft.net>
References: <1502421389-20152-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: xiangxia.m.yue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753638AbdHKVqK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:46:10 -0400
In-Reply-To: <1502421389-20152-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Date: Thu, 10 Aug 2017 20:16:29 -0700

> Because we remove the UFO support, we will also remove the
> CHECKSUM_UNNECESSARY check in skb_needs_check().
> 
> Cc: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>

Applied, thank you.
