From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: mediatek: get out of potential
 invalid pointer access
Date: Thu, 22 Sep 2016 08:23:27 -0400 (EDT)
Message-ID: <20160922.082327.2293980535291845076.davem@davemloft.net>
References: <1474533856-22753-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com, objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474533856-22753-1-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <sean.wang@mediatek.com>
Date: Thu, 22 Sep 2016 16:44:16 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> Potential dangerous invalid pointer might be accessed if
> the error happens when couple phy_device to net_device so
> cleanup the error path.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Applied.
