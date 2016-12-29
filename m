From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] stmmac: enable rx queues
Date: Thu, 29 Dec 2016 11:53:28 -0500 (EST)
Message-ID: <20161229.115328.567699953533520388.davem@davemloft.net>
References: <44464911a078d7494e1a968a2df6d2ad3401ef1c.1482929644.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sandeepkishan108@gmail.com
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752513AbcL2Qxd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 11:53:33 -0500
In-Reply-To: <44464911a078d7494e1a968a2df6d2ad3401ef1c.1482929644.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed, 28 Dec 2016 12:57:48 +0000

> When the hardware is synthesized with multiple queues, all queues are
> disabled for default. This patch adds the rx queues configuration.
> This patch was successfully tested in a Synopsys QoS Reference design.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Applied, thanks.
