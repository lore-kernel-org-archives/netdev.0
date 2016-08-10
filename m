From: Dave Jones <davej@codemonkey.org.uk>
Subject: e1000: __pskb_pull_tail failed
Date: Tue, 9 Aug 2016 23:57:20 -0400
Message-ID: <20160810035720.7qfwwtqr2xw337yq@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:42968 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932657AbcHJD5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 23:57:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MY NFS server running 4.8-rc1 is getting flooded with this message:

e1000e 0000:00:19.0 eth0: __pskb_pull_tail failed.

Never saw it happen with 4.7 or earlier.


That device is this onboard NIC: 

00:19.0 Ethernet controller: Intel Corporation Ethernet Connection (2) I218-V

	Dave
