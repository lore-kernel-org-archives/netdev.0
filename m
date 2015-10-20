From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 241/245]
 drivers/net/ethernet/hisilicon/hns/hnae.c:442:1-3: WARNING: PTR_ERR_OR_ZERO
 can be used
Date: Tue, 20 Oct 2015 14:56:00 +0800
Message-ID: <201510201454.XwPbNrDe%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11007 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051AbbJTG51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 02:57:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   7b4b000951f09cfe3604a6fdf5469894b4e75adb
commit: 876133d3161dcb743983d1f9e5bf247aea2fb0f1 [241/245] net: hisilicon: add OF dependency


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/hisilicon/hns/hnae.c:442:1-3: WARNING: PTR_ERR_OR_ZERO can be used

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
