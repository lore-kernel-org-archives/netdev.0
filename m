From: Andrew Morton <akpm@linux-foundation.org>
Subject: nacked netdev patches
Date: Wed, 30 Jul 2008 12:40:27 -0700
Message-ID: <20080730124027.95b0f98a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59358 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753126AbYG3Tlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:41:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've been sitting on four patches basically for ever.  I _think_ the
issues which they address are still real, but perhaps some of them are
really dead.  Can we please go through them and work out what to do
with them?

They are:

e1000e-make-e1000e-default-to-the-same-kconfig-setting-as-e1000.patch
3x59x-fix-pci-resource-management.patch
update-smc91x-driver-with-arm-versatile-board-info.patch
smc-ultra-get-rid-of-eth%d-message.patch


Thanks.
