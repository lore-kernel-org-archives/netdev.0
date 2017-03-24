From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: use setup_deferrable_timer
Date: Fri, 24 Mar 2017 14:43:03 -0700 (PDT)
Message-ID: <20170324.144303.1499801244994529133.davem@davemloft.net>
References: <8333b4c5b4aef4b847b1132d52c214764c41ebe5.1490340639.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933123AbdCXVnT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:43:19 -0400
In-Reply-To: <8333b4c5b4aef4b847b1132d52c214764c41ebe5.1490340639.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geliang Tang <geliangtang@gmail.com>
Date: Fri, 24 Mar 2017 22:14:36 +0800

> Use setup_deferrable_timer() instead of init_timer_deferrable() to
> simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied, thanks.
