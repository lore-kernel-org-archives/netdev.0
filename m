From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: hix5hd2_gmac: keep the compatible string not
 changed
Date: Tue, 20 Dec 2016 14:13:47 -0500 (EST)
Message-ID: <20161220.141347.359771649872892693.davem@davemloft.net>
References: <1482199769-106501-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, linux@armlinux.org.uk,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com, arnd@arndb.de,
        andrew@lunn.ch, xuejiancheng@hisilicon.com,
        benjamin.chenhao@hisilicon.com, caizhiyong@hisilicon.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: lidongpo@hisilicon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482199769-106501-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dongpo Li <lidongpo@hisilicon.com>
Date: Tue, 20 Dec 2016 10:09:27 +0800

> This patch series fix the patch:
> d0fb6ba75dc0 ("net: hix5hd2_gmac: add generic compatible string")
> 
> The SoC hix5hd2 compatible string has the suffix "-gmac" and
> we should not change its compatible string.
> So we should name all the compatible string with the suffix "-gmac".
> Creating a new name suffix "-gemac" is unnecessary.

Series applied.
