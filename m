From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net-next: mediatek: add support for
 ethernet on MT7622 SoC
Date: Tue, 11 Jul 2017 20:53:04 -0700 (PDT)
Message-ID: <20170711.205304.168426733833873080.davem@davemloft.net>
References: <cover.1499829241.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1499829241.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <sean.wang@mediatek.com>
Date: Wed, 12 Jul 2017 11:37:41 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> The series adds the driver for ethernet controller found on MT7622 SoC.
> There are additions against with previous MT7623 SoC such as shared SGMII
> given for the dual GMACs and built-in 5-ports 10/100 embedded switch support
> (ESW). Thus more clocks consumers and SGMII hardware setup for the extra
> features are all introduced here and as for the support for ESW that would be
> planned to add in the separate patch integrating with DSA infrastructure
> in the future.
> 
> Currently testing successfully is done with those patches for the conditions
> such as GMAC2 with IP1001 PHY via RGMII and GMAC1/2 with RTL8211F PHY via SGMII.

net-next is closed, please resubmit this when net-next is open again:

	http://vger.kernel.org/~davem/net-next.html

Thanks.
