From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: wan: slic_ds26522: Use
 module_spi_driver to simplify the code
Date: Tue, 07 Feb 2017 11:42:46 -0500 (EST)
Message-ID: <20170207.114246.682073329893222093.davem@davemloft.net>
References: <1476715845-27691-1-git-send-email-weiyj.lk@gmail.com>
        <20170206152552.8549-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: javier@osg.samsung.com, qiang.zhao@nxp.com,
        colin.king@canonical.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51318 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755420AbdBGQmu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:42:50 -0500
In-Reply-To: <20170206152552.8549-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon,  6 Feb 2017 15:25:52 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> module_spi_driver() makes the code simpler by eliminating
> boilerplate code.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
