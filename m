From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib_rules: fix error return code
Date: Thu, 27 Apr 2017 16:36:20 -0400 (EDT)
Message-ID: <20170427.163620.292717346900073871.davem@davemloft.net>
References: <20170426140350.25451-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, idosch@mellanox.com, dsa@cumulusnetworks.com,
        mateusz.bajorski@nokia.com, johannes.berg@intel.com,
        weiyongjun1@huawei.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968485AbdD0UgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 16:36:25 -0400
In-Reply-To: <20170426140350.25451-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 26 Apr 2017 14:03:50 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return error code -EINVAL from the error handling
> case instead of 0, as done elsewhere in this function.
> 
> Fixes: 622ec2c9d524 ("net: core: add UID to flows, rules, and routes")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied, thank you.
