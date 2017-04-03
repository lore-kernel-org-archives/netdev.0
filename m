From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: fix cbs configuration
Date: Sun, 02 Apr 2017 19:30:36 -0700 (PDT)
Message-ID: <20170402.193036.284334416255180558.davem@davemloft.net>
References: <fba7548363a0a3300bdc28679da8bd7bae91b24e.1490959712.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niklas.cassel@axis.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41328 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751692AbdDCCao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 22:30:44 -0400
In-Reply-To: <fba7548363a0a3300bdc28679da8bd7bae91b24e.1490959712.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Fri, 31 Mar 2017 14:22:02 +0100

> Sending again, because forgot to include net-dev.
> 
> The QoS IP does not accept AVB capabilities to default/queue 0, this way we
> guarantee 75% bandwidth for AVB. This patch assures that only queues >= 1
> gets CBS confgured. Additional info was also added to stmmac.txt.
> 
> Reported-by: Niklas Cassel <niklas.cassel@axis.com>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Applied, thanks.
