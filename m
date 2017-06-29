From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET V7 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Thu, 29 Jun 2017 09:35:32 +0800
Message-ID: <0445a290-50ae-98f4-f3ff-9e5520147f3d@huawei.com>
References: <1498641191-13343-1-git-send-email-linyunsheng@huawei.com>
 <1498641191-13343-2-git-send-email-linyunsheng@huawei.com>
 <20170628132750.GA12559@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <f.fainelli@gmail.com>,
        <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <salil.mehta@huawei.com>,
        <lipeng321@huawei.com>, <tremyfr@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170628132750.GA12559@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/6/28 21:27, Andrew Lunn wrote:
> On Wed, Jun 28, 2017 at 05:13:10PM +0800, Lin Yun Sheng wrote:
>> This patch add set_loopback in phy_driver, which is used by MAC
>> driver to enable or disable phy loopback. it also add a generic
>> genphy_loopback function, which use BMCR loopback bit to enable
>> or disable loopback.
>>
>> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
> 
> Hi Lin
> 
> It is normal to include my
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> 
> when resubmitting a patch. The only time you drop such tags is when
> you make a big change.
Will do next time, thanks for reviewing.

Best Regards
Yunsheng Lin
