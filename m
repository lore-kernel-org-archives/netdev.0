From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [RFT] r8169 changes against 2.6.21-rc4
Date: Fri, 16 Mar 2007 21:49:46 +0100
Message-ID: <20070316204946.GA17436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50460 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753655AbXCPUvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 16:51:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Boring week-end in sight ?

The new serie of r8169 changes is available at:
http://www.fr.zoreil.com/people/francois/misc/20070316-2.6.21-rc4-r8169-test.patch

or:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc4/r8169-20070316

or (rebase happy branch):
git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git#r8169

Please do not clone your whole git kernel tree from here, thanks.


Changes (most recent first):
- mac address change support
- align the IP header when there is no DMA constraint
- add bit description for the TxPoll register
- MSI support
- cleanup
- remove the media option
- small 8101 comment
- confusion between hardware and IP header alignment
- merge with version 8.001.00 of Realtek's r8168 driver
- merge with version 6.001.00 of Realtek's r8169 driver
- add per-device hw_start handler (2/2)
- add per-device hw_start handler (1/2)
- fix suspend/resume for down interface

-- 
Ueimor
