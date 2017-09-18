From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] forcedeth: replace pci_map_single with
 dma_map_single functions
Date: Mon, 18 Sep 2017 14:49:01 -0700 (PDT)
Message-ID: <20170918.144901.349238163227276483.davem@davemloft.net>
References: <1505444511-27231-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750982AbdIRVtJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:49:09 -0400
In-Reply-To: <1505444511-27231-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Thu, 14 Sep 2017 23:01:51 -0400

> pci_map_single functions are obsolete. So replace them with
> dma_map_single functions.
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied, thanks.
