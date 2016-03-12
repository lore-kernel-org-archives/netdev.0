From: Leon Romanovsky <leon@leon.nu>
Subject: Re: [PATCH 0/3] infiniband: IB/hns: Hisilicon RoCE support
Date: Sat, 12 Mar 2016 12:20:51 +0200
Message-ID: <20160312102051.GC11383@leon.nu>
References: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
Reply-To: leon@leon.nu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 11, 2016 at 06:37:08PM +0800, Lijun Ou wrote:

1) It is redundant to write "infiniband" and "IB" in one title to mention
relevant subsystem, since it is the same.

Please take a look on the other submissions here on the list and use
similar construction.

2) Please use version number in the titles [PATCH vXXX]

> The Hisilicon Network Substem(hns) is a long term evolution IP which is
> supposed to be used in Hisilicon ICT SoC. RoCE is a feature of hns.
> The driver for Hisilicon RoCE engine is a platform driver.
> The driver will support mulitple versions of hns. Currently only "v1"
> for hip06 SOC is supported.
> 
> 
> Changes v1 -> v2:
> 1. adjust the formats of roce driver code by the experts reviewing
> 2. modify the bindings file with roce dts. add the attribute named 
> interrput-names.
> 3. modify the way of defining port mode in hns_dsaf_main.c
> 4. move the Kconfig file into the hns directory and send it with roce
> driver code file together.
> 
> 
> Lijun Ou (3):
>   infiniband: IB/hns: add Hisilicon RoCE support
>   net: hns: add Hisilicon RoCE support
>   infiniband: IB/hns: add Hisilicon RoCE support with bindings
> 
