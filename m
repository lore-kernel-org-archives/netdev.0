From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [net-2.6 2.6.33] WiMAX pull request
Date: Fri, 22 Jan 2010 15:14:40 -0800
Message-ID: <cover.1264138318.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:58837 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755447Ab0AVXRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:17:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It might be quite late already for this (conceptually) one liner
patch, submitting just in case. This was a last minute issue we found,
were some i6050 parts have different USB IDs.


The following changes since commit b94b50289622e816adc9f94111cfc2679c80177c:
  Jesse Brandeburg (1):
        e1000e: enhance frame fragment detection

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git linux-2.6.33.y

Patches follow for reviewing convenience.

Inaky Perez-Gonzalez (1):
      wimax/i2400m: Add support for more i6x50 SKUs

 drivers/net/wimax/i2400m/i2400m-usb.h |    2 ++
 drivers/net/wimax/i2400m/usb.c        |   12 +++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)
