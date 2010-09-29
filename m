From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] qcusbnet: Cleanups
Date: Tue, 28 Sep 2010 19:39:56 -0700
Message-ID: <cover.1285727642.git.joe@perches.com>
References: <20100928171026.GB6083@google.com>
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	mjg59@srcf.ucam.org, jglasgow@google.com, msb@google.com,
	olofj@google.com
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2508 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192Ab0I2CkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 22:40:00 -0400
In-Reply-To: <20100928171026.GB6083@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perhaps some of these cleanups are in order?

Joe Perches (2):
  drivers/net/usb/qcusbnet: Checkpatch cleanups
  drivers/net/usb/qcusbnet/qmidevice: Remove printhex, use print_hex_dump

 drivers/net/usb/qcusbnet/qcusbnet.c  |  201 ++++++----------
 drivers/net/usb/qcusbnet/qmi.c       |   32 ++--
 drivers/net/usb/qcusbnet/qmidevice.c |  451 ++++++++++++++++------------------
 drivers/net/usb/qcusbnet/qmidevice.h |    1 -
 drivers/net/usb/qcusbnet/structs.h   |   25 +--
 5 files changed, 307 insertions(+), 403 deletions(-)

-- 
1.7.3.1.g432b3.dirty

