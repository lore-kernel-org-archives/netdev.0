From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] lan78xx: Remove trailing underscores from macros
Date: Tue,  6 Sep 2016 16:04:32 -0700
Message-ID: <cover.1473202982.git.joe@perches.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (2):
  lan78xx: Remove locally defined trailing underscores from defines and uses
  microchipphy.h and uses: Remove trailing underscores from defines and uses

 drivers/net/phy/microchip.c  |    4 +-
 drivers/net/usb/lan78xx.c    |  368 +++++++--------
 drivers/net/usb/lan78xx.h    | 1068 +++++++++++++++++++++---------------------
 include/linux/microchipphy.h |   72 +--
 4 files changed, 756 insertions(+), 756 deletions(-)

-- 
2.10.0.rc2.1.g053435c
