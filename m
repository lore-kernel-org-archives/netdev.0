From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2] vmxnet3: fix non static symbol warning
Date: Thu, 25 Aug 2016 16:43:24 -0700 (PDT)
Message-ID: <20160825.164324.765029838383701713.davem@redhat.com>
References: <1471964718-32543-1-git-send-email-weiyj.lk@gmail.com>
        <1472051246-15097-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: skhare@vmware.com, pv-drivers@vmware.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37650 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756487AbcHYXna (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 19:43:30 -0400
In-Reply-To: <1472051246-15097-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 24 Aug 2016 15:07:26 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/net/vmxnet3/vmxnet3_drv.c:1645:1: warning:
>  symbol 'vmxnet3_rq_destroy_all_rxdataring' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied to net-next.
