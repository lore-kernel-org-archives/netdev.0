From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/5] treewide: Convert logging message misuses of /n to \n
Date: Thu, 24 Apr 2014 18:50:58 -0700
Message-ID: <cover.1398390579.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org,
	alsa-devel@alsa-project.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (5):
  qlge: Convert /n to \n
  iwlegacy: Convert /n to \n
  staging: rtl<foo>: Convert /n to \n
  appledisplay: Convert /n to \n
  sound: tlv320aic31xx: Convert /n to \n

 drivers/net/ethernet/qlogic/qlge/qlge_main.c  | 2 +-
 drivers/net/wireless/iwlegacy/3945.c          | 2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c      | 2 +-
 drivers/staging/rtl8188eu/hal/usb_ops_linux.c | 2 +-
 drivers/staging/rtl8188eu/os_dep/usb_intf.c   | 2 +-
 drivers/staging/rtl8723au/hal/usb_ops_linux.c | 4 ++--
 drivers/staging/rtl8723au/os_dep/usb_intf.c   | 2 +-
 drivers/usb/misc/appledisplay.c               | 2 +-
 sound/soc/codecs/tlv320aic31xx.c              | 2 +-
 9 files changed, 10 insertions(+), 10 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
