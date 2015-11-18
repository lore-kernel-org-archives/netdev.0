From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet/atheros/alx: add Killer E2400 device ID
Date: Wed, 18 Nov 2015 15:06:42 -0500 (EST)
Message-ID: <20151118.150642.1281703908211053053.davem@davemloft.net>
References: <1447809667-9454-1-git-send-email-jason@system76.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benpope81@gmail.com
To: jason@system76.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200AbbKRUGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 15:06:44 -0500
In-Reply-To: <1447809667-9454-1-git-send-email-jason@system76.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Gerard DeRose <jason@system76.com>
Date: Tue, 17 Nov 2015 18:21:07 -0700

> From: Ben Pope <benpope81@gmail.com>
> 
> This patch adds the PCI device ID (0xe0a1) and alx_pci_tbl entry for the
> Killer E2400 Ethernet controller, modeled after the Killer E2200
> controller support (0xe091) already present in the alx driver.
> 
> This patch was originally authored by Ben Pope, but it got held up by
> issues in the commit message, so I'm resubmitting it on his behalf.
> 
> I've extensively used a kernel with this patch on a System76 serw9
> laptop and am quite confident it works well (at least on the hardware I
> have available for testing).
> 
> Note that as a favor to System76, Ubuntu has been carrying this as a
> sauce patch in their 4.2 based Wily kernel, which presumably has given
> it real-world testing on other E2400 equipped hardware (I don't know of
> any Ubuntu kernel bugs filed about it):
> 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1498633
> 
> Signed-off-by: Jason Gerard DeRose <jason@system76.com>

Applied.
