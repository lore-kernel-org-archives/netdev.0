From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH rfc 1/4] net/utils: generic inet_pton_with_scope helper
Date: Fri, 17 Feb 2017 05:34:00 +0800
Message-ID: <201702170514.zqhVrek9%fengguang.wu@intel.com>
References: <1487267017-29904-2-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, linux-nvme@lists.infradead.org,
        linux-rdma@vger.kernel.org, target-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57029 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933107AbdBPVeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 16:34:09 -0500
Content-Disposition: inline
In-Reply-To: <1487267017-29904-2-git-send-email-sagi@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sagi,

[auto build test WARNING on linus/master]
[also build test WARNING on v4.10-rc8 next-20170216]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Sagi-Grimberg/Introduce-a-new-helper-for-parsing-ipv-4-6-port-to-socket-address/20170217-015537


coccinelle warnings: (new ones prefixed by >>)

>> net/core/utils.c:388:2-3: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
