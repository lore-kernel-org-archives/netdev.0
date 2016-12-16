From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: ethernet: hisilicon: set dev->dev.parent
 before PHY connect
Date: Fri, 16 Dec 2016 13:30:16 -0500 (EST)
Message-ID: <20161216.133016.1389137786566303117.davem@davemloft.net>
References: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        f.fainelli@gmail.com, xuejiancheng@hisilicon.com,
        benjamin.chenhao@hisilicon.com, caizhiyong@hisilicon.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: lidongpo@hisilicon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dongpo Li <lidongpo@hisilicon.com>
Date: Mon, 12 Dec 2016 20:03:41 +0800

> This patch series builds atop:
> ec988ad78ed6d184a7f4ca6b8e962b0e8f1de461 ("phy: Don't increment MDIO bus
> refcount unless it's a different owner")
> 
> I have checked all the hisilicon ethernet driver and found only two drivers
> need to be fixed to make sure set dev->dev.parent before PHY connect.

Series applied, thanks.
