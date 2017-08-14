From: Ohad Oz <ohado@mellanox.com>
Subject: [patch v2 0/2] Enable Mellanox switch device in I2C mode
Date: Mon, 14 Aug 2017 15:38:20 +0000
Message-ID: <1502725102-182550-1-git-send-email-ohado@mellanox.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, saeedm@mellanox.com,
        vadimp@mellanox.com, system-sw-low-level@mellanox.com,
        Ohad Oz <ohado@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46315 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752401AbdHNNlU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 09:41:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch set updates global to Mellanox Kconfig files to support
configuration of Mellanox Switch (mlxsw) without PCI and with I2C only.

Ohad Oz (2):
  Allow Mellanox switch devices to be configured if only I2C bus is set
  Change Kconfig description

 drivers/net/ethernet/mellanox/Kconfig | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

-- 
2.1.4
