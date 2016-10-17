From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: wan: slic_ds26522: Use module_spi_driver to
 simplify the code
Date: Mon, 17 Oct 2016 13:09:36 -0400 (EDT)
Message-ID: <20161017.130936.227547446361095372.davem@davemloft.net>
References: <1476715845-27691-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: javier@osg.samsung.com, qiang.zhao@nxp.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030328AbcJQRJi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:09:38 -0400
In-Reply-To: <1476715845-27691-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 17 Oct 2016 14:50:45 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> module_spi_driver() makes the code simpler by eliminating
> boilerplate code.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

These two patches do not apply cleanly to net-next, please respin.
