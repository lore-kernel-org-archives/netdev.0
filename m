From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-next/hinic: Set Rxq irq to specific cpu
 for NUMA
Date: Thu, 28 Sep 2017 10:27:09 -0700 (PDT)
Message-ID: <20170928.102709.693274037894359435.davem@davemloft.net>
References: <1506448670-51213-1-git-send-email-aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: aviad.krawczyk@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506448670-51213-1-git-send-email-aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Date: Wed, 27 Sep 2017 01:57:50 +0800

> Set Rxq irq to specific cpu for allocating and receiving the skb from
> the same node.
> 
> Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>

Applied.
