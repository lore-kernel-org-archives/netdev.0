From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v4 0/2] net_sched: clean up tc filter destroy
 and delete logic
Date: Fri, 21 Apr 2017 13:59:03 -0400 (EDT)
Message-ID: <20170421.135903.2113303465508075015.davem@davemloft.net>
References: <1492636882-19571-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35890 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423128AbdDUR7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 13:59:05 -0400
In-Reply-To: <1492636882-19571-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 19 Apr 2017 14:21:20 -0700

> The first patch fixes a potenial race condition, the second one
> is pure cleanup.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Series applied, thanks.
