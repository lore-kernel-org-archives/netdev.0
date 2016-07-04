From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 1/2] net: pktgen: support injecting packets
 for qdisc testing
Date: Mon, 04 Jul 2016 16:07:53 -0700 (PDT)
Message-ID: <20160704.160753.1955777291648177547.davem@davemloft.net>
References: <20160702211254.13884.81202.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, brouer@redhat.com, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:51156 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753729AbcGDXHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 19:07:54 -0400
In-Reply-To: <20160702211254.13884.81202.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sat, 02 Jul 2016 14:12:54 -0700

> Add another xmit_mode to pktgen to allow testing xmit functionality
> of qdiscs. The new mode "queue_xmit" injects packets at
> __dev_queue_xmit() so that qdisc is called.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
