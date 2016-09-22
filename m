From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: mediatek: fix missing changes
 merged for conflicts overlapping commits
Date: Thu, 22 Sep 2016 02:05:26 -0400 (EDT)
Message-ID: <20160922.020526.1971593537856081147.davem@davemloft.net>
References: <1474386804-11728-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbcIVGFa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:05:30 -0400
In-Reply-To: <1474386804-11728-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sean.wang@mediatek.com>
Date: Tue, 20 Sep 2016 23:53:24 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> add the missing commits about
> 1)
> Commit d3bd1ce4db8e843dce421e2f8f123e5251a9c7d3
> ("remove redundant free_irq for devm_request_ir allocated irq")
> 2)
> Commit 7c6b0d76fa02213393815e3b6d5e4a415bf3f0e2
> ("fix logic unbalance between probe and remove")
> 
> during merge for conflicts overlapping commits by
> Commit b20b378d49926b82c0a131492fa8842156e0e8a9
> ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Applied, thanks for fixing this up for me.
