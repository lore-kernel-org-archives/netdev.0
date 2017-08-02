From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 0/2] drivers/net: add const to bin_attribute structures
Date: Wed,  2 Aug 2017 23:27:12 +0530
Message-ID: <1501696634-15765-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, harish.patil@cavium.com,
        manish.chopra@cavium.com, Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare bin_attribute structures as const.

Bhumika Goyal (2):
  wlcore: add const to bin_attribute structure
  qlcnic: add const to bin_attribute structure

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 2 +-
 drivers/net/wireless/ti/wlcore/sysfs.c            | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

-- 
1.9.1
