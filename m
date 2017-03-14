From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 net-next 00/11] net: stmmac: prepare dma operations for
 multiple queues
Date: Tue, 14 Mar 2017 18:26:34 +0000
Message-ID: <e00fe491-8f72-bdaf-9776-b72a7446f9ca@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
 <20170314.112152.1192292460063519158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:40732 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdCNS0j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 14:26:39 -0400
In-Reply-To: <20170314.112152.1192292460063519158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 6:21 PM de 3/14/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Tue, 14 Mar 2017 10:24:22 +0000
> 
>> As agreed with David Miller, this patch-set is the second of 3 to enable
>> multiple queues in stmmac.
>>
>> This second one concentrates on dma operations adding functionalities as:
>> a) DMA Operation Mode configuration per channel and done in the multiple
>> queues configuration function
>> b) DMA IRQ enable and Disable by channel
>> c) DMA start and stop by channel
>> d) RX and TX ring length configuration by channel
>> e) RX and TX set tail pointer by channel
>> f) DMA Channel initialization broke into Channel comon, RX and TX
>> initialization
>> g) TSO being configured for all available channels
>> h) DMA interrupt treatment by channel
> 
> Patch #5 doesn't apply cleanly to net-next, please respin this series.
> 
> Thank you.
> 

Ok, I will rebase it and send you a v3 tomorrow. Thanks.
