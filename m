From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3] Add missing commas
Date: Fri,  8 Jul 2011 23:20:22 -0700
Message-ID: <cover.1310187270.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A patch to staging/gma500 found a missing comma in
arrays declarations.  Here are some others.

Joe Perches (3):
  benet: Add missing comma between constant string array
  iwlegacy: Add missing comma between constant string array
  iwlagn: Add missing comma between constant string array

 drivers/net/benet/be_main.c                  |    6 +++---
 drivers/net/wireless/iwlegacy/iwl4965-base.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

-- 
1.7.6.131.g99019
