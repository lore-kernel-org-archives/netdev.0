From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] drivers/net: Remove trailing semicolons from do {...} while 0 macros
Date: Wed, 14 May 2014 12:15:12 -0700
Message-ID: <cover.1400094804.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (2):
  ti: Remove trailing semicolon from do {...} while (0) macro
  wlcore: Remove trailing semicolon from do {...} while (0) macro

 drivers/net/ethernet/ti/cpsw.c           | 4 ++--
 drivers/net/wireless/ti/wlcore/debugfs.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
