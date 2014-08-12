From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] myri10ge: check for DMA mapping errors
Date: Tue, 12 Aug 2014 14:28:49 -0700 (PDT)
Message-ID: <20140812.142849.1415932719133747116.davem@davemloft.net>
References: <20140812083518.GA1836@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hykim@myri.com
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbaHLV2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 17:28:50 -0400
In-Reply-To: <20140812083518.GA1836@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Tue, 12 Aug 2014 10:35:19 +0200

> On IOMMU systems DMA mapping can fail, we need to check for 
> that possibility.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> v1 -> v2: check also for errors on myri10ge_xmit() 

Applied and queued up for -stable, thank you.
