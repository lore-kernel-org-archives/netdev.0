From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [5/8]
Date: Thu, 19 Jul 2007 09:40:46 +0100
Message-ID: <20070719084046.GC2936@infradead.org>
References: <469EEE95.8050500@realitydiluted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44625 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936429AbXGSIkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 04:40:47 -0400
Content-Disposition: inline
In-Reply-To: <469EEE95.8050500@realitydiluted.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 18, 2007 at 11:54:45PM -0500, Steven J. Hill wrote:
> Fix 'mv643xx_eth_tx_timeout_task' function prototype.

Patches 5-7 look like valid fixes independent of the merge.  Please send
them out inlined in the mail and with proper subjects so they can be
merged independent of the GT/MV642xx support.
