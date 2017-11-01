From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] forcedeth: replace pci_alloc_consistent
 with dma_alloc_coherent
Date: Wed, 01 Nov 2017 12:03:46 +0900 (KST)
Message-ID: <20171101.120346.554130814781385463.davem@davemloft.net>
References: <1509193530-25321-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, netdev@vger.kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754102AbdKADDu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:03:50 -0400
In-Reply-To: <1509193530-25321-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Sat, 28 Oct 2017 08:25:30 -0400

> The functions pci_alloc_consistent is obsolete. So it is replaced
> with dma_alloc_coherent
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied, thanks.
