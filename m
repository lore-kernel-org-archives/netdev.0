From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/2] mlx5 minor SRIOV fixes
Date: Tue,  8 Dec 2015 23:56:49 +0200
Message-ID: <1449611811-30573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	saeedm@dev.mellanox.co.il, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:40436 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750975AbbLHV5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 16:57:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This short series fixes some minor issues in recently
introduced SRIOV code.
 
Saeed.

Saeed Mahameed (2):
  net/mlx5: Fix query E-Switch capabilities
  net/mlx5e: Assign random MAC address if needed

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    5 +++++
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |    2 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    3 +++
 3 files changed, 9 insertions(+), 1 deletions(-)
