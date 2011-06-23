From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/8] 8390: Neatening
Date: Wed, 22 Jun 2011 23:38:52 -0700
Message-ID: <cover.1308810463.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some updates requested by Geert Uytterhoeven

Joe Perches (8):
  ariadne: Update style, neaten, restructure to eliminate prototypes
  a2065: Use pr_fmt, pr_<level> and netdev_<level>
  lib8390: Use pr_<level> and netdev_<level>
  lib8390: Indent braces appropriately
  lib8390: Normalize source code spacing
  lib8390: Convert include <asm to include <linux
  lib8390: Remove unnecessary extern
  zorro8390: Restructure and eliminate prototypes

 drivers/net/a2065.c     |  336 ++++++-------
 drivers/net/ariadne.c   | 1267 ++++++++++++++++++++++-------------------------
 drivers/net/lib8390.c   |  285 +++++------
 drivers/net/zorro8390.c |  673 +++++++++++++-------------
 4 files changed, 1220 insertions(+), 1341 deletions(-)

-- 
1.7.6.rc3
