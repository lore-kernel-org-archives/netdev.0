From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 0/3] adding new glue driver dwmac-dwc-qos-eth
Date: Mon, 09 Jan 2017 14:54:51 -0500 (EST)
Message-ID: <20170109.145451.1987809584514692654.davem@davemloft.net>
References: <cover.1483964586.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, niklass@axis.com, swarren@nvidia.com,
        treding@nvidia.com, netdev@vger.kernel.org, nathan.sullivan@ni.com
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754978AbdAITyx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:54:53 -0500
In-Reply-To: <cover.1483964586.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Mon, 9 Jan 2017 12:35:07 +0000

> This patch set contains the porting of the synopsys/dwc_eth_qos.c driver
> to the stmmac structure. This operation resulted in the creation of a new
> platform glue driver called dwmac-dwc-qos-eth which was based in the
> dwc_eth_qos as is.
> 
> dwmac-dwc-qos-eth inherited dwc_eth_qos DT bindings, to assure that current
> and old users can continue to use it as before. We can see this driver as
> being deprecated, since all new development will be done in stmmac.
> 
> Please check each patch for implementation details.

Series applied, thanks Joao.
