From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/4] drivers/net: Remove unnecessary [kv][mcz]alloc casts
Date: Sun, 28 Nov 2010 01:05:42 -0800
Message-ID: <cover.1290934782.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are the last remaining alloc casts in drivers/net...

Joe Perches (4):
  netxen: remove unnecessary [kv][mcz]alloc casts
  qlcnic: remove unnecessary [kv][mcz]alloc casts
  vxge: remove unnecessary [kv][mcz]alloc casts
  zd1211rw: remove unnecessary [kv][mcz]alloc casts

 drivers/net/netxen/netxen_nic_init.c    |    3 +--
 drivers/net/qlcnic/qlcnic_init.c        |    3 +--
 drivers/net/vxge/vxge-config.c          |   24 +++++++++---------------
 drivers/net/vxge/vxge-main.c            |    4 +---
 drivers/net/wireless/zd1211rw/zd_chip.c |    3 +--
 5 files changed, 13 insertions(+), 24 deletions(-)

-- 
1.7.3.2.245.g03276.dirty
