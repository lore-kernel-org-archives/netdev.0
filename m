From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: use netif_set_real_num_{rx,tx}_queues
Date: Tue, 11 Apr 2017 22:21:22 -0400 (EDT)
Message-ID: <20170411.222122.498286060501464190.davem@davemloft.net>
References: <f0359c3d65fbb3f5220c23fc2833c4a094bec4a5.1491819975.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751992AbdDLCVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 22:21:24 -0400
In-Reply-To: <f0359c3d65fbb3f5220c23fc2833c4a094bec4a5.1491819975.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Mon, 10 Apr 2017 11:32:14 +0100

> In the submission of the lastest multiple buffer patch set, this fix was lost.
> I am sending this patch to put it right again. The fix was originally proposed
> by Arnd Bergmann.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Applied, thanks for catching this.
