From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next V1 18/18] net/mlx5e: Add support for SR-IOV ndos
Date: Mon, 30 Nov 2015 00:35:50 +0800
Message-ID: <201511300052.hucIGXEo%fengguang.wu@intel.com>
References: <1448811446-18598-19-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52825 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbbK2QgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2015 11:36:24 -0500
Content-Disposition: inline
In-Reply-To: <1448811446-18598-19-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Saeed,

[auto build test WARNING on: net-next/master]
[also build test WARNING on: v4.4-rc2 next-20151127]

url:    https://github.com/0day-ci/linux/commits/Or-Gerlitz/Introducing-ConnectX-4-Ethernet-SRIOV/20151129-234342


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:1970:2-3: Unneeded semicolon
   drivers/net/ethernet/mellanox/mlx5/core/en_main.c:1959:2-3: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
