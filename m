From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH RESEND net-next 0/3] dts: hisi: fixes can't find eth for
 hip05-D02
Date: Sat, 5 Dec 2015 15:47:26 +0800
Message-ID: <5662968E.9050206@huawei.com>
References: <1449302088-53037-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>, <xuwei5@hisilicon.com>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<wangkefeng.wang@huawei.com>, <dingtianhong@huawei.com>,
	<liguozhu@huawei.com>, <Yisen.Zhuang@huawei.com>,
	<sboyd@codeaurora.org>, <haojian.zhuang@linaro.org>,
	<wangzhou1@hisilicon.com>, <bintian.wang@huawei.com>,
	<long.wanglong@huawei.com>, <leo.yan@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449302088-53037-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sorry, pls ignore this patchset.

On 2015/12/5 15:54, yankejian wrote:
> this patchset fixes the bug that eth can't initial successful on hip05-D02
> because the dts files doesn't match the source code.
>
> yankejian (3):
>   dts: hisi: enables the ethX for D02 board
>   dts: hisi: fixes no syscon error when init mdio
>   arm64: hip05-d02: Document devicetree bindings for Hisilicon D02 Board
>
>  .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
>  arch/arm64/boot/dts/hisilicon/hip05-d02.dts              | 16 ++++++++++++++++
>  arch/arm64/boot/dts/hisilicon/hip05.dtsi                 |  4 ++++
>  arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi             |  4 ++--
>  4 files changed, 38 insertions(+), 2 deletions(-)
>
