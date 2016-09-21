From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] net: ethernet: mediatek: add support for
 GMAC0 connecting with external PHY through TRGMII
Date: Wed, 21 Sep 2016 00:50:36 -0400 (EDT)
Message-ID: <20160921.005036.970962076834416813.davem@davemloft.net>
References: <1474358360-29901-1-git-send-email-sean.wang@mediatek.com>
        <1474358360-29901-3-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbcIUEuj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 00:50:39 -0400
In-Reply-To: <1474358360-29901-3-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sean.wang@mediatek.com>
Date: Tue, 20 Sep 2016 15:59:19 +0800

> +/*TRGMII RXC control register*/
 ...
> +/*TRGMII RXC control register*/
 ...
> +/*TRGMII Interface mode register*/


Please put a space at the beginning and end of comment lines like this.

Thanks.
