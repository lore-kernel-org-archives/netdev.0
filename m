From: Suresh Reddy <suresh.reddy@broadcom.com>
Subject: [PATCH net-next 0/2] be2net: patch-set
Date: Wed, 24 May 2017 22:24:37 -0400
Message-ID: <1495679079-12025-1-git-send-email-suresh.reddy@broadcom.com>
References: <Suresh.Reddy@broadcom.com>
Cc: Suresh Reddy <suresh.reddy@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.232.149]:56953 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932341AbdEYCab (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 22:30:31 -0400
In-Reply-To: <Suresh.Reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Please consider applying these two patches to net-next

Suresh Reddy (2):
  be2net: Fix UE detection logic for BE3
  be2net: Update the driver version to 11.4.0.0

 drivers/net/ethernet/emulex/benet/be.h      |  2 +-
 drivers/net/ethernet/emulex/benet/be_hw.h   |  3 +++
 drivers/net/ethernet/emulex/benet/be_main.c | 27 +++++++++++++++++++--------
 3 files changed, 23 insertions(+), 9 deletions(-)

-- 
1.8.3.1
