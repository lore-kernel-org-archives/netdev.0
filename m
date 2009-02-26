From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/5][net-next] qlge: Clean up and non-functional changes.
Date: Thu, 26 Feb 2009 12:07:46 -0800
Message-ID: <20090226200746.GA23769@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:10083 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756084AbZBZULE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:11:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These 5 patches are mostly non-logical changes.  They are preparatory to
adding more support for firmware events and adding the new device ID.

0001--net-next-qlge-Add-defines-for-firmware-support.patch
0002--net-next-qlge-Clean-up-firmware-reset-path.patch
0003--net-next-qlge-Move-firmware-event-handler.patch
0004--net-next-qlge-Prepare-to-add-new-device.patch
0005--net-next-qlge-Reduce-debug-print-output.patch

Thanks,
Ron Mercer

