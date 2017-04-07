From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4 v3 net-next] net: stmmac: adding multiple buffers
Date: Fri, 07 Apr 2017 07:18:57 -0700 (PDT)
Message-ID: <20170407.071857.1140644831091281319.davem@davemloft.net>
References: <cover.1491467980.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clabbe.montjoie@gmail.com, treding@nvidia.com,
        niklas.cassel@axis.com, julia.lawall@lip6.fr,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755318AbdDGOS7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 10:18:59 -0400
In-Reply-To: <cover.1491467980.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Thu,  6 Apr 2017 09:49:07 +0100

> This patch adds multiple buffers to stmmac in a more fragmented
> way, in order to make problem debug easier.
> 
> I would kindly request to people to test this patch in their HWs in
> order to check if everything's functional. Thank you.

Looks like there has been a bit of testing, so I'll apply this series.

Thanks.
