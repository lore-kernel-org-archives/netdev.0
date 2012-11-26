From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 20/25] warning: (NET_DSA_TAG_DSA &&
 NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet
 direct dependencies (NET && EXPERIMENTAL && NETDEVICES && !S390)
Date: Mon, 26 Nov 2012 12:56:10 +0800
Message-ID: <50b2f66a.czw+uqRm3Q/zfbER%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viresh kumar <viresh.kumar@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3984 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754351Ab2KZE4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2012 23:56:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   53d6841d225b93c20d561878637c3cd307c11648
commit: 82167cb8c6b2f8166d5c7532e5ef4b5e0cc46a72 [20/25] net: dsa/slave: Fix compilation warnings
config: make ARCH=s390 allmodconfig

All warnings:

warning: (NET_DSA_TAG_DSA && NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet direct dependencies (NET && EXPERIMENTAL && NETDEVICES && !S390)
warning: (NET_DSA_TAG_DSA && NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet direct dependencies (NET && EXPERIMENTAL && NETDEVICES && !S390)
--
warning: (NET_DSA_TAG_DSA && NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet direct dependencies (NET && EXPERIMENTAL && NETDEVICES && !S390)

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
