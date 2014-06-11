From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Adds support for CIQ and other misc.
 fixes for rdma/cxgb4
Date: Tue, 10 Jun 2014 22:50:24 -0700 (PDT)
Message-ID: <20140610.225024.792402488502072865.davem@davemloft.net>
References: <1402071045-14854-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	roland@purestorage.com, swise@opengridcomputing.com,
	santosh@chelsio.com, leedom@chelsio.com, dm@chelsio.com,
	kumaras@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbaFKFuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 01:50:25 -0400
In-Reply-To: <1402071045-14854-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  6 Jun 2014 21:40:41 +0530

> This patch series adds support to allocate and use IQs specifically for
> indirect interrupts, adds fixes to align ISS for iWARP connections & fixes
> related to tcp snd/rvd window for Chelsio T4/T5 adapters on iw_cxgb4.
> Also changes Interrupt Holdoff Packet Count threshold of response queues for
> cxgb4 driver.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4 and iw_cxgb4 driver.
> 
> Since this patch-series contains cxgb4 and iw_cxgb4 patches, we would like to
> request this patch series to get merged via David Miller's 'net-next' tree.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
