From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net:master 10/12] drivers/net/phy/smsc.c:127:3-4: Unneeded semicolon
Date: Tue, 18 Aug 2015 06:31:42 +0800
Message-ID: <201508180640.tFfxPCXM%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Igor Plyatov <plyatov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58525 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbbHQWcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 18:32:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
head:   af19e68683ba9c29e778d0f8be5be61a0ebb4166
commit: 776829de90c5972895db398993ddfa9417ff8b01 [10/12] net: phy: workaround for buggy cable detection by LAN8700 after cable plugging


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/phy/smsc.c:127:3-4: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
