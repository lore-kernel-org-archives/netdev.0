From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/9] Typo fixes of faild to failed
Date: Thu, 21 Oct 2010 22:17:11 -0700
Message-ID: <cover.1287724261.git.joe@perches.com>
Cc: linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
	cbe-oss-dev@lists.ozlabs.org, linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, rtc-linux@googlegroups.com,
	osd-dev@open-osd.org, jfs-discussion@lists.sourceforge.net
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-ide-owner@vger.kernel.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (9):
  drivers/ata: typo fix of faild to failed
  drivers/gpu: typo fix of faild to failed
  drivers/net: typo fix of faild to failed
  drivers/rtc: typo fix of faild to failed
  drivers/video: typo fix of faild to failed
  fs/exofs: typo fix of faild to failed
  fs/jfs: typo fix of faild to failed
  kernel/trace: typo fix of faild to failed
  net/wanrouter: typo fix of faild to failed

 drivers/ata/pata_bf54x.c           |    2 +-
 drivers/gpu/drm/radeon/radeon_cs.c |    2 +-
 drivers/net/ps3_gelic_net.c        |    4 ++--
 drivers/net/tulip/pnic2.c          |    2 +-
 drivers/rtc/rtc-nuc900.c           |    2 +-
 drivers/video/bf54x-lq043fb.c      |    6 +++---
 drivers/video/bfin-t350mcqb-fb.c   |    2 +-
 fs/exofs/dir.c                     |    4 ++--
 fs/exofs/inode.c                   |   14 +++++++-------
 fs/exofs/ios.c                     |   10 +++++-----
 fs/jfs/jfs_mount.c                 |    4 ++--
 kernel/trace/trace_kprobe.c        |    2 +-
 net/wanrouter/wanmain.c            |    4 ++--
 13 files changed, 29 insertions(+), 29 deletions(-)

-- 
1.7.3.1.g432b3.dirty

