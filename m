From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] usbnet: style cleaning and logging
Date: Tue,  3 May 2011 11:17:56 -0700
Message-ID: <cover.1304445019.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just a spring cleaning for the new maintainer to deal with...

Joe Perches (2):
  usbnet: Style cleanups
  usbnet: Convert dbg to dev_dbg and neatening.

 drivers/net/usb/usbnet.c |  638 +++++++++++++++++++++++-----------------------
 1 files changed, 325 insertions(+), 313 deletions(-)

-- 
1.7.5.rc3.dirty
