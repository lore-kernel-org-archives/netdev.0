From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 376/390]
 drivers/net/ethernet/qualcomm/emac/emac-ethtool.c:155:49-50: Unneeded
 semicolon
Date: Wed, 8 Feb 2017 03:41:56 +0800
Message-ID: <201702080337.4IVnIpzh%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44566 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754998AbdBGTpc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 14:45:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   ca6d4480f87db9d9470d3d7bbe445953fa105e57
commit: b44700e975848a9a569a509244672ff886ec99b3 [376/390] net: qcom/emac: add ethool support for setting pause parameters


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/qualcomm/emac/emac-ethtool.c:155:49-50: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
