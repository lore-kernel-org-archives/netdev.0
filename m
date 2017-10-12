From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net: qcom/emac: enforce DMA address restrictions
Date: Thu, 12 Oct 2017 10:20:53 -0700 (PDT)
Message-ID: <20171012.102053.1670394834782672563.davem@davemloft.net>
References: <e523734d-d845-8eae-4a5b-e679b8e46654@codeaurora.org>
        <20171012.095837.2057549694773237248.davem@davemloft.net>
        <4f0055bb-894f-8fe1-b2d3-b6541dbb07a7@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756577AbdJLRUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:20:54 -0400
In-Reply-To: <4f0055bb-894f-8fe1-b2d3-b6541dbb07a7@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Thu, 12 Oct 2017 12:15:12 -0500

> On 10/12/2017 11:58 AM, David Miller wrote:
>>> I'm pretty sure that kzalloc does not make that guarantee, and I don't
>>> think dma_alloc_coherent does either.
>> Both make that guarantee, even when an IOMMU is used.
>> 
> 
> Ok, Dave, then can you drop this patch?

Please send me a patch.
