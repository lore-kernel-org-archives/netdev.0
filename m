From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: efx_get_phys_port_id() can be static
Date: Wed, 11 Jan 2017 16:12:35 -0500 (EST)
Message-ID: <20170111.161235.1084117606892550280.davem@davemloft.net>
References: <20170111161612.14384-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59576 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760130AbdAKVNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:13:36 -0500
In-Reply-To: <20170111161612.14384-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 11 Jan 2017 16:16:12 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/net/ethernet/sfc/efx.c:2337:5: warning:
>  symbol 'efx_get_phys_port_id' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
