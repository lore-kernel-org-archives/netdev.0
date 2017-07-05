From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net 0/3] Bugfixs for hns ethernet driver
Date: Wed, 5 Jul 2017 16:30:09 +0800
Message-ID: <eee1e130-0a9e-af41-889e-e23d73d53acc@huawei.com>
References: <1499165253-184543-1-git-send-email-linyunsheng@huawei.com>
 <c1077130-1ecd-ef95-4182-ffc167aace2b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <salil.mehta@huawei.com>,
        <lipeng321@huawei.com>, <tremyfr@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c1077130-1ecd-ef95-4182-ffc167aace2b@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Florian

On 2017/7/5 0:56, Florian Fainelli wrote:
> On 04/07/2017 03:47, Lin Yun Sheng wrote:
>> This patchset fix skb uesd after used, C45 op code and
>> Tx description filling issues in hns driver.
> 
> Since these are fixes, can you include proper Fixes: tag so it is easier
> for -stable maintainers to backport such changes where appropriate?
Thanks for pointing out. Will add it next version.

Best Regards
YunshengLin
