From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] net_sched: use idr to allocate basic
 filter handles
Date: Thu, 28 Sep 2017 09:44:09 -0700 (PDT)
Message-ID: <20170928.094409.970234776196582035.davem@davemloft.net>
References: <20170925171351.4956-2-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrism@mellanox.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751689AbdI1QoJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 12:44:09 -0400
In-Reply-To: <20170925171351.4956-2-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 25 Sep 2017 10:13:50 -0700

> Instead of calling basic_get() in a loop to find
> a unused handle, just switch to idr API to allocate
> new handles.
> 
> Cc: Chris Mi <chrism@mellanox.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
