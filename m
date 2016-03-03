From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 963/985]
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:115:15-21: ERROR:
 application of sizeof to pointer
Date: Thu, 3 Mar 2016 09:55:19 +0800
Message-ID: <201603030907.6ptkaLfJ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	Alexandre TORGUE <alexandre.torgue@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24528 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754380AbcCCB4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 20:56:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   3ebeac1d029550a860ea2d034bf1c7f1de52d442
commit: afea03656add70a0e00f5b0039f87288c7af8b9f [963/985] stmmac: rework DMA bus setting and introduce new platform AXI structure


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:115:15-21: ERROR: application of sizeof to pointer

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
