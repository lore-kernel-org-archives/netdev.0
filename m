From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 0/3] Bugfixs for hns ethernet driver
Date: Tue, 4 Jul 2017 09:56:18 -0700
Message-ID: <c1077130-1ecd-ef95-4182-ffc167aace2b@gmail.com>
References: <1499165253-184543-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lin Yun Sheng <linyunsheng@huawei.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34749 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752490AbdGDQ40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 12:56:26 -0400
In-Reply-To: <1499165253-184543-1-git-send-email-linyunsheng@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2017 03:47, Lin Yun Sheng wrote:
> This patchset fix skb uesd after used, C45 op code and
> Tx description filling issues in hns driver.

Since these are fixes, can you include proper Fixes: tag so it is easier
for -stable maintainers to backport such changes where appropriate?
