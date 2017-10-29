From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: aquantia: Make local functions static
Date: Sun, 29 Oct 2017 17:53:27 +0900 (KST)
Message-ID: <20171029.175327.1243681613239258090.davem@davemloft.net>
References: <1509167018-92434-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tremyfr@gmail.com, vomlehn@texas.net, pavel.belous@aquantia.com,
        igor.russkikh@aquantia.com, Dmitrii.Tarakanov@aquantia.com,
        Alexander.Loktionov@aquantia.com, netdev@vger.kernel.org
To: weiyongjun1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47086 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751080AbdJ2Ixf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 04:53:35 -0400
In-Reply-To: <1509167018-92434-1-git-send-email-weiyongjun1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>
Date: Sat, 28 Oct 2017 05:03:38 +0000

> Fixes the following sparse warnings:
> 
> drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c:224:5: warning:
>  symbol 'aq_ethtool_get_coalesce' was not declared. Should it be static?
> drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c:245:5: warning:
>  symbol 'aq_ethtool_set_coalesce' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
