From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmicro: fix LS field mask in EEE configuration
Date: Sun, 22 Jan 2017 16:49:53 -0500 (EST)
Message-ID: <20170122.164953.874236089744264438.davem@davemloft.net>
References: <ed690f703a3c82193737f1a9813dff8b1ff403dd.1484927665.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rayagond@vayavyalabs.com, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAVVtz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 16:49:55 -0500
In-Reply-To: <ed690f703a3c82193737f1a9813dff8b1ff403dd.1484927665.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Fri, 20 Jan 2017 16:00:26 +0000

> This patch fixes the LS mask when setting EEE timer.
> LS field is 10 bits long and not 11 as currently.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> Reported-By: Rayagond Kokatanur <rayagond@vayavyalabs.com>

Please indicate the appropriate target tree of your patch in the
subject line just like all other developers on this list do, don't
make me guess.

This time I figured out that this is meant for the net-next tree,
but I will not guess next time, I will just reject your patch
instead.

Thanks.
