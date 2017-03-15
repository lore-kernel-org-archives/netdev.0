From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 00/11] net: stmmac: prepare dma operations
 for multiple queues
Date: Wed, 15 Mar 2017 14:44:46 -0700 (PDT)
Message-ID: <20170315.144446.84996623298168099.davem@davemloft.net>
References: <cover.1489575025.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54352 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbdCOVou (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 17:44:50 -0400
In-Reply-To: <cover.1489575025.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed, 15 Mar 2017 11:04:44 +0000

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

Series applied.
