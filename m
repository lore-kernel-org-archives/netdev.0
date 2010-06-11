From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35] WiMAX pull request
Date: Fri, 11 Jun 2010 12:03:05 -0700
Message-ID: <cover.1276282933.git.inaky.perez-gonzalez@intel.com>
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6815 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756458Ab0FKTHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 15:07:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>

The following changes since commit 3a24934f065d23145f1c9c70da9f630c7a37795f:
  Inaky Perez-Gonzalez (1):
        wimax/i2400m: fix bad race condition check in RX path

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git wimax-2.6.35.y

Patches follow for reviewing convenience.

Inaky Perez-Gonzalez (1):
      wimax/i2400m: fix missing endian correction read in fw loader

 drivers/net/wimax/i2400m/fw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)
