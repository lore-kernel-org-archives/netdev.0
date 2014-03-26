From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 3/3] xen-netback: Functional follow-up
 patch for grant mapping series
Date: Wed, 26 Mar 2014 16:34:09 -0400 (EDT)
Message-ID: <20140326.163409.1699058249447731491.davem@davemloft.net>
References: <1395705591-23976-1-git-send-email-zoltan.kiss@citrix.com>
	<1395705591-23976-3-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, paul.durrant@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jonathan.davies@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288AbaCZUeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 16:34:12 -0400
In-Reply-To: <1395705591-23976-3-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 24 Mar 2014 23:59:51 +0000

> Ian made some late comments about the grant mapping series, I incorporated the
> functional outcomes into this patch:
> 
> - use callback_param macro to shorten access to pending_tx_info in
>   xenvif_fill_frags() and xenvif_tx_submit()
> - print an error message in xenvif_idx_unmap() before panic
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Applied.
