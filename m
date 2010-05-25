From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35] WiMAX pull request
Date: Tue, 25 May 2010 10:45:12 -0700
Message-ID: <cover.1274809476.git.inaky.perez-gonzalez@intel.com>
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:26854 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751024Ab0EYRsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 13:48:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>

The following changes since commit 0fb0a4f00aaf5de9f328273d7a46e3aa27dab496:
  Inaky Perez-Gonzalez (1):
        wimax/i2400m: driver defaults to firmware v1.5 for i6x60 devices

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git wimax-2.6.35.y

Patches follow for reviewing convenience.

Inaky Perez-Gonzalez (1):
      wimax/i2400m: fix bad race condition check in RX path

 drivers/net/wimax/i2400m/rx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)
