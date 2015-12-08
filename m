From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 3/3] geneve: Remote Checksum Offload support
Date: Wed, 9 Dec 2015 04:45:25 +0800
Message-ID: <201512090439.hQej6KX5%fengguang.wu@intel.com>
References: <1449599238-4094072-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	jesse@nicira.com, linville@tuxdriver.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58593 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594AbbLHUqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 15:46:16 -0500
Content-Disposition: inline
In-Reply-To: <1449599238-4094072-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Tom-Herbert/rco-Clean-up-casting-errors/20151209-022902


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/geneve.c:371:6-12: ERROR: application of sizeof to pointer

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
