From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/2] Fix crash caused by reporting inconsistent
 skb->len to BQL
Date: Mon, 17 Apr 2017 13:34:23 -0400 (EDT)
Message-ID: <20170417.133423.1964068698419105282.davem@davemloft.net>
References: <1492139952-8104-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55880 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752751AbdDQReZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:34:25 -0400
In-Reply-To: <1492139952-8104-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sean.wang@mediatek.com>
Date: Fri, 14 Apr 2017 11:19:10 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> Changes since v1:
> - fix inconsistent enumeration which easily causes the potential bug

Series applied, thanks.
