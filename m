From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "rtnetlink: check DO_SETLINK_NOTIFY
 correctly in do_setlink"
Date: Fri, 27 Oct 2017 22:27:42 +0900 (KST)
Message-ID: <20171027.222742.957021050844741067.davem@davemloft.net>
References: <47e8fd3f-fa47-0e3b-1041-b931c64aa45b@6wind.com>
        <20171026082153.8042-1-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        vyasevic@redhat.com, dsahern@gmail.com, lucien.xin@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49624 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751908AbdJ0N1q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 09:27:46 -0400
In-Reply-To: <20171026082153.8042-1-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 26 Oct 2017 10:21:53 +0200

> This reverts commit 64ff90cc2e6f42596d7a0c37e41dc95292bb63b1.
> 
> The initial test was right. The goal is to advertised any modifications of
> any setting of a link. The test ensures that the user won't lose an update.
> 
> CC: David Ahern <dsahern@gmail.com>
> CC: Xin Long <lucien.xin@gmail.com>
> Reported-by: Vlad Yasevich <vyasevic@redhat.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

As requested I've dropped this patch.

Thank you.
