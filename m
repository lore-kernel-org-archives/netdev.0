From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] net: ethernet: mediatek: check the hw
 lro capability by the chip id instead of the dtsi
Date: Thu, 06 Oct 2016 21:08:34 -0400 (EDT)
Message-ID: <20161006.210834.726391081639977552.davem@davemloft.net>
References: <1475754243-12557-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, nelsonch.tw@gmail.com
To: nelson.chang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935974AbcJGBIk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 21:08:40 -0400
In-Reply-To: <1475754243-12557-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson Chang <nelson.chang@mediatek.com>
Date: Thu, 6 Oct 2016 19:44:00 +0800

> The series modify to check if hw lro is supported by the chip id.
> 
> changes since v3:
> - Refine mtk_is_hwlro_supported() function
> 
> changes since v2:
> - Refine mtk_get_chip_id() function
> 
> changes since v1:
> - Because hw lro started to be supported from MT7623, the proper way to check if the feature is capable is to judge by the chip id instead of by the dtsi.

Series applied, thanks.
