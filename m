From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/11] net: stmmac: prepare dma operations
 for multiple queues
Date: Tue, 14 Mar 2017 11:21:52 -0700 (PDT)
Message-ID: <20170314.112152.1192292460063519158.davem@davemloft.net>
References: <cover.1489485739.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48394 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdCNSV7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 14:21:59 -0400
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Tue, 14 Mar 2017 10:24:22 +0000

> As agreed with David Miller, this patch-set is the second of 3 to enable
> multiple queues in stmmac.
> 
> This second one concentrates on dma operations adding functionalities as:
> a) DMA Operation Mode configuration per channel and done in the multiple
> queues configuration function
> b) DMA IRQ enable and Disable by channel
> c) DMA start and stop by channel
> d) RX and TX ring length configuration by channel
> e) RX and TX set tail pointer by channel
> f) DMA Channel initialization broke into Channel comon, RX and TX
> initialization
> g) TSO being configured for all available channels
> h) DMA interrupt treatment by channel

Patch #5 doesn't apply cleanly to net-next, please respin this series.

Thank you.
