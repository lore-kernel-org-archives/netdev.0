From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v6 13/13] net: ethernet: aquantia: Integrate AQtion 2.5/5
 GB NIC driver
Date: Thu, 19 Jan 2017 17:09:31 +0800
Message-ID: <201701191708.e8q1JvlR%fengguang.wu@intel.com>
References: <bfce3d39db5d3cf8cac5e1cf355ffe13c2a08b4c.1484788010.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        David VomLehn <vomlehn@texas.net>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18907 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751303AbdASJMi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 04:12:38 -0500
Content-Disposition: inline
In-Reply-To: <bfce3d39db5d3cf8cac5e1cf355ffe13c2a08b4c.1484788010.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.10-rc4 next-20170118]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Alexander-Loktionov/net-ethernet-aquantia-Make-and-configuration-files/20170119-133339


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/aquantia/atlantic/aq_ring.c:24:20-41: WARNING: casting value returned by memory allocation function to (struct aq_ring_buff_s *) is useless.

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
