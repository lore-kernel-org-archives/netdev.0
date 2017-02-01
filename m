From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ethernet: aquantia: fix dma_mapping_error test
Date: Wed, 01 Feb 2017 12:45:38 -0500 (EST)
Message-ID: <20170201.124538.2087709954972565603.davem@davemloft.net>
References: <20170201085215.GB31514@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vomlehn@texas.net, Dmitry.Bezrukov@aquantia.com,
        Pavel.Belous@aquantia.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41218 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753524AbdBARpu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:45:50 -0500
In-Reply-To: <20170201085215.GB31514@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 1 Feb 2017 11:52:15 +0300

> dma_mapping_error() returns 1 if there is an error and 0 if not.
> 
> Fixes: 018423e90bee ("net: ethernet: aquantia: Add ring support code")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
