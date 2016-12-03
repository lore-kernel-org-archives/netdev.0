From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: hns: Fix to conditionally convey RX
 checksum flag to stack
Date: Sat, 03 Dec 2016 15:25:15 -0500 (EST)
Message-ID: <20161203.152515.1155017126921048869.davem@davemloft.net>
References: <20161129130945.919372-1-salil.mehta@huawei.com>
        <20161130.142539.1927956259851457047.davem@davemloft.net>
        <F4CC6FACFEB3C54C9141D49AD221F7F91A7D5EF1@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A7D5EF1@lhreml503-mbx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta@huawei.com>
Date: Thu, 1 Dec 2016 16:59:14 +0000

> It looks to me the cumbersome check in the PATCH V2 should
> be retained.

I really want something simpler with small checks that are
done in logical pieces in a straigtforward progression.

The code in V2 is completely unreadable.
