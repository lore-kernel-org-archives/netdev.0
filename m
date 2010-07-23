From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35] WiMAX pull request
Date: Thu, 22 Jul 2010 17:15:13 -0700
Message-ID: <cover.1279843906.git.inaky.perez-gonzalez@intel.com>
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:34290 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756194Ab0GWATu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 20:19:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>

Hello David

This is a simple patch to add the USB IDs for another SKU of the Intel
6250. I understand that it might be too late to get it into 2.6.35,
but I'd like to ask if it is possible.

Thank you,

The following changes since commit a385a53e659b35ebee604889e21c40e5c336941f:
  Inaky Perez-Gonzalez (1):
        wimax/i2400m: fix missing endian correction read in fw loader

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git wimax-2.6.35.y

Patches follow for reviewing convenience.

Alexey Shvetsov (1):
      wimax/i2400m: Add PID & VID for Intel WiMAX 6250

 drivers/net/wimax/i2400m/i2400m-usb.h |    1 +
 drivers/net/wimax/i2400m/usb.c        |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)
