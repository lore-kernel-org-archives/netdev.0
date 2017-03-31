From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net 08/19] net: hns: Fix to adjust buf_size of ring
 according to mtu
Date: Sat, 1 Apr 2017 07:50:55 +0800
Message-ID: <201704010733.8LNMN4m7%fengguang.wu@intel.com>
References: <20170330153106.14344-9-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, salil.mehta@huawei.com,
        yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com, lipeng <lipeng321@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170330153106.14344-9-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi lipeng,

[auto build test WARNING on net/master]

url:    https://github.com/0day-ci/linux/commits/Salil-Mehta/net-hns-Misc-HNS-Bug-Fixes-Code-Improvements/20170401-060153


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/hisilicon/hns/hns_enet.c:1548:8-9: WARNING: return of 0/1 in function 'hns_enable_serdes_lb' with return type bool

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
