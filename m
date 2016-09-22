From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: mediatek: use phydev from
 struct net_device
Date: Thu, 22 Sep 2016 08:23:09 -0400 (EDT)
Message-ID: <20160922.082309.1617081787333578116.davem@davemloft.net>
References: <1474533215-22273-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com, objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474533215-22273-1-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <sean.wang@mediatek.com>
Date: Thu, 22 Sep 2016 16:33:35 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> reuse phydev already in struct net_device instead of creating
> another new one in private structure.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Applied.
