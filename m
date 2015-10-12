From: huangdaode <huangdaode@hisilicon.com>
Subject: Re: [PATCH net-next 0/2] net: fix some bugs in HNS drivers
Date: Mon, 12 Oct 2015 10:34:39 +0800
Message-ID: <561B1C3F.4070108@hisilicon.com>
References: <1444285045-23275-1-git-send-email-huangdaode@hisilicon.com> <20151011.050252.1499118063121905989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>,
	<salil.mehta@huawei.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151011.050252.1499118063121905989.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/10/11 20:02, David Miller wrote:
> From: huangdaode <huangdaode@hisilicon.com>
> Date: Thu, 8 Oct 2015 14:17:23 +0800
>
>> This patchset fixes the two bugs in HNS driver, one is for fixing the
>> compilation warning bug on arm 32-bit platform, another is fixing the wrong
>> mac port judgement bug which is found during internal tests.
> This patch series does not apply to the net-next tree at all.
>
> Also, both patches should use a subsystem prefix of "hisilicon: "
> in the Subject lines.
>
> Thanks.
>
> .
>

Thanks David,
Because it conflicts with arnd's patches,  which fixes this bug.
in the mail, Joe Perches advised another fix, we will send out the patch 
soon.
thanks

-- 
Best Regards
Daode Huang
