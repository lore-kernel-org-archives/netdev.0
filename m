From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET_DMA: remove unused dma_memcpy_to_kernel_iovec
Date: Thu, 26 Jul 2007 00:06:07 -0700 (PDT)
Message-ID: <20070726.000607.18303016.davem@davemloft.net>
References: <20070725003606.11018.15141.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ftp.linux.org.uk,
	christopher.leech@intel.com, andy.grover@gmail.com
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760652AbXGZHGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 03:06:09 -0400
In-Reply-To: <20070725003606.11018.15141.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@intel.com>
Date: Tue, 24 Jul 2007 17:36:06 -0700

> (repost - original eaten by vger?)
> 
> Al Viro pointed out that dma_memcpy_to_kernel_iovec() really was
> unreachable and thus unused.  The code originally was there to support
> in-kernel dma needs, but since it remains unused, we'll pull it out.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>

Applied, thanks Shannon.
