From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cdc-ether: usbnet_cdc_zte_status() can be
 static
Date: Thu, 12 Jan 2017 11:09:41 -0500 (EST)
Message-ID: <20170112.110941.1808004349333485081.davem@davemloft.net>
References: <20170112134347.22793-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, weiyongjun1@huawei.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbdALQKB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:10:01 -0500
In-Reply-To: <20170112134347.22793-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 12 Jan 2017 13:43:47 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/net/usb/cdc_ether.c:469:6: warning:
>  symbol 'usbnet_cdc_zte_status' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
