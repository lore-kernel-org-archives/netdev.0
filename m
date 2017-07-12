From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v1 net-next 4/5] drop_monitor: let drop stat support net
 ns
Date: Thu, 13 Jul 2017 02:44:57 +0800
Message-ID: <201707130239.LITQp931%fengguang.wu@intel.com>
References: <1499856053-30475-4-git-send-email-zhangjunweimartin@didichuxing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, nhorman@tuxdriver.com, davem@davemloft.net,
        netdev@vger.kernel.org, martinbj2008@gmail.com,
        zhangjunweimartin@didichuxing.com
To: martinbj2008@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:48859 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752434AbdGLSpo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Jul 2017 14:45:44 -0400
Content-Disposition: inline
In-Reply-To: <1499856053-30475-4-git-send-email-zhangjunweimartin@didichuxing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi martin,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/martinbj2008-gmail-com/drop_monitor-import-netnamespace-framework/20170712-205015


coccinelle warnings: (new ones prefixed by >>)

>> net/core/drop_monitor.c:555:36-37: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
