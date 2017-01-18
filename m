From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmicro: add more information to Kconfig
Date: Wed, 18 Jan 2017 12:12:19 -0500 (EST)
Message-ID: <20170118.121219.276079547111027170.davem@davemloft.net>
References: <8e4b7bbd48a0b2ff1374fdffe6d07dc00659e951.1484664500.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751074AbdARRNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 12:13:04 -0500
In-Reply-To: <8e4b7bbd48a0b2ff1374fdffe6d07dc00659e951.1484664500.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Tue, 17 Jan 2017 14:53:07 +0000

> This patch adds more info to stmicro' Kconfig files in order to be clearer
> that the driver can be used by ethernet cards based on 10/100/1000/EQOS
> Synopsys IP Cores.
> 
> EQOS was also added stmmac/Kconfig Kconfig, since dwmac4 is in fact EQoS,
> one of Synopsys Ethernet IPs. More info at:
> https://www.synopsys.com/dw/ipdir.php?ds=dwc_ether_qos
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Applied.
