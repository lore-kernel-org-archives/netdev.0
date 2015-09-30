From: kbuild test robot <lkp@intel.com>
Subject: Re: [RFC v3 net-next 05/10] qede: Add basic network device support
Date: Wed, 30 Sep 2015 21:48:15 +0800
Message-ID: <201509302150.a1QzjRP8%fengguang.wu@intel.com>
References: <1443618217-18069-6-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15125 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166AbbI3NuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 09:50:03 -0400
Content-Disposition: inline
In-Reply-To: <1443618217-18069-6-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sudarsana,

[auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/qlogic/qede/qede_main.c:2141:1-3: WARNING: end returns can be simpified and declaration on line 2134 can be dropped

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
