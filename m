From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ne2000: add the right platform device
Date: Tue, 20 Nov 2012 13:49:44 -0500 (EST)
Message-ID: <20121120.134944.1886479320568117408.davem@davemloft.net>
References: <20121120163157.11874.74810.stgit@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469Ab2KTStp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 13:49:45 -0500
In-Reply-To: <20121120163157.11874.74810.stgit@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 20 Nov 2012 16:31:57 +0000

> From: Alan Cox <alan@linux.intel.com>
> 
> Without this udev doesn't have a way to key the ne device to the platform
> device.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied and queued up for -stable, thanks Alan.
