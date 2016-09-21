From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: mediatek: enhance with
 avoiding superfluous assignment inside mtk_get_ethtool_stats
Date: Wed, 21 Sep 2016 00:07:32 -0400 (EDT)
Message-ID: <20160921.000732.1476178907311873337.davem@davemloft.net>
References: <1474342008-22496-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33122 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752415AbcIUEHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 00:07:35 -0400
In-Reply-To: <1474342008-22496-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sean.wang@mediatek.com>
Date: Tue, 20 Sep 2016 11:26:48 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> data_src is unchanged inside the loop, so this patch moves
> the assignment to outside the loop to avoid unnecessarily
> assignment
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Applied.
