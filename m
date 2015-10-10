From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next] bnxt_en: New Broadcom ethernet driver.
Date: Sat, 10 Oct 2015 20:24:21 +0800
Message-ID: <201510102046.oAPUHudL%fengguang.wu@intel.com>
References: <1444477151-2225-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10067 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751484AbbJJM0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2015 08:26:13 -0400
Content-Disposition: inline
In-Reply-To: <1444477151-2225-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please ignore]


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/broadcom/bnxt/bnxt.c:2773:41-42: WARNING: Use ARRAY_SIZE
--
>> drivers/net/ethernet/broadcom/bnxt/bnxt.c:1290:5-7: Unneeded variable: "rc". Return "0" on line 1304
--
>> drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c:521:5-7: Unneeded variable: "rc". Return "0" on line 595
--
>> drivers/net/ethernet/broadcom/bnxt/bnxt.c:2763:30-31: Unneeded semicolon
--
>> drivers/net/ethernet/broadcom/bnxt/bnxt.c:4071:1-3: WARNING: end returns can be simpified and declaration on line 4064 can be dropped
--
>> drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c:156:1-3: WARNING: end returns can be simpified and declaration on line 154 can be dropped
   drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c:140:1-3: WARNING: end returns can be simpified and declaration on line 138 can be dropped

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
