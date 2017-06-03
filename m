From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v3 4/7] net: pch_gbe: Add device tree support
Date: Sat, 3 Jun 2017 14:36:42 +0800
Message-ID: <201706031442.vYKOKOkq%fengguang.wu@intel.com>
References: <20170602234042.22782-5-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        Tobias Klauser <tklauser@distanz.ch>,
        "David S . Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>, linux-mips@linux-mips.org,
        Eric Dumazet <edumazet@google.com>,
        Paul Burton <paul.burton@imgtec.com>
To: Paul Burton <paul.burton@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64840 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750765AbdFCGgx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Jun 2017 02:36:53 -0400
Content-Disposition: inline
In-Reply-To: <20170602234042.22782-5-paul.burton@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.12-rc3 next-20170602]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Paul-Burton/net-pch_gbe-Fixes-MIPS-support/20170603-112042


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c:2587:9-16: WARNING: ERR_CAST can be used with gpio

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
