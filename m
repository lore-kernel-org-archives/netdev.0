From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netdma: adding alignment check for NETDMA ops
Date: Wed, 04 Apr 2012 20:18:26 -0400 (EDT)
Message-ID: <20120404.201826.979310574458628758.davem@davemloft.net>
References: <20120404230749.20605.7000.stgit@djiang5-linux.ch.intel.com>
	<20120404231046.20605.13918.stgit@djiang5-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dave.jiang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab2DEAS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 20:18:29 -0400
In-Reply-To: <20120404231046.20605.13918.stgit@djiang5-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jiang <dave.jiang@intel.com>
Date: Wed, 04 Apr 2012 16:10:46 -0700

> This is the fallout from adding memcpy alignment workaround for certain
> IOATDMA hardware. NetDMA will only use DMA engine that can handle byte align
> ops.
> 
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>

Acked-by: David S. Miller <davem@davemloft.net>
