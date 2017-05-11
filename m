From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net 0/2] qlcnic: Bug fix and update version
Date: Thu, 11 May 2017 07:12:46 -0700
Message-ID: <20170511141248.996-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0064.outbound.protection.outlook.com ([104.47.33.64]:7676
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932128AbdEKONI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 11 May 2017 10:13:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series has one fix and bumps up driver version.
Please consider applying to "net"

Thanks,
Manish

Manish Chopra (2):
  qlcnic: Fix link configuration with autoneg disabled
  qlcnic: Update version to 5.3.66

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  4 +--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 34 ++++++++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  3 ++
 4 files changed, 40 insertions(+), 2 deletions(-)

-- 
2.7.2
