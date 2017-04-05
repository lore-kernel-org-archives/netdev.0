From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: stmmac: rx queue to dma channel mapping
 fix
Date: Wed, 05 Apr 2017 06:47:57 -0700 (PDT)
Message-ID: <20170405.064757.359067290785577913.davem@davemloft.net>
References: <4532d68ceefa4d0327275036698b3ec0e7b967c8.1491233596.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42028 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752304AbdDENsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 09:48:05 -0400
In-Reply-To: <4532d68ceefa4d0327275036698b3ec0e7b967c8.1491233596.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Mon,  3 Apr 2017 16:34:04 +0100

> In hardware configurations where multiple queues are active,
> the rx queue needs to be mapped into a dma channel, even if
> a single rx queue is used.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Applied, thanks.
