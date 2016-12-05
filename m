From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next] net: hns: Fix to conditionally convey RX
 checksum flag to stack
Date: Mon, 5 Dec 2016 15:42:35 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A7DDD3F@lhreml503-mbx>
References: <20161129130945.919372-1-salil.mehta@huawei.com>
        <20161130.142539.1927956259851457047.davem@davemloft.net>
        <F4CC6FACFEB3C54C9141D49AD221F7F91A7D5EF1@lhreml503-mbx>
 <20161203.152515.1155017126921048869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161203.152515.1155017126921048869.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, December 03, 2016 8:25 PM
> To: Salil Mehta
> Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next] net: hns: Fix to conditionally convey
> RX checksum flag to stack
> 
> From: Salil Mehta <salil.mehta@huawei.com>
> Date: Thu, 1 Dec 2016 16:59:14 +0000
> 
> > It looks to me the cumbersome check in the PATCH V2 should
> > be retained.
> 
> I really want something simpler with small checks that are
> done in logical pieces in a straigtforward progression.
> 
> The code in V2 is completely unreadable.
Hi David,
I understand your concern. I have floated the Patch V3 with
re-structured code for your review. Thanks!

Best regards
Salil
