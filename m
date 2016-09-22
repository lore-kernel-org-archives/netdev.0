From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: mediatek: remove superfluous
 local variable for phy address
Date: Thu, 22 Sep 2016 08:23:15 -0400 (EDT)
Message-ID: <20160922.082315.1292178294636800365.davem@davemloft.net>
References: <1474533375-22423-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com, objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474533375-22423-1-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <sean.wang@mediatek.com>
Date: Thu, 22 Sep 2016 16:36:15 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> remove the unused variable for parsing PHY address
> and the related logic for sanity test which would
> be all already handled done when of_mdiobus_register
> was called
> 
> Reported-by: Nelson Chang <nelson.chang@mediatek.com>
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Applied.
