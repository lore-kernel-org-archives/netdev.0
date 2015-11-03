From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next v3] mpls: support for dead routes
Date: Tue, 3 Nov 2015 23:25:39 +0800
Message-ID: <201511032333.Lf2mqx0D%fengguang.wu@intel.com>
References: <1446562191-22416-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, ebiederm@xmission.com, rshearma@brocade.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25654 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964934AbbKCP1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 10:27:15 -0500
Content-Disposition: inline
In-Reply-To: <1446562191-22416-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roopa,

[auto build test WARNING on net-next/master]
[also WARNING on: next-20151103]

url:    https://github.com/0day-ci/linux/commits/Roopa-Prabhu/mpls-support-for-dead-routes/20151103-225234
base:   https://github.com/0day-ci/linux Roopa-Prabhu/mpls-support-for-dead-routes/20151103-225234


coccinelle warnings: (new ones prefixed by >>)

>> net/mpls/af_mpls.c:722:22-23: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
