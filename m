From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Add MPS tracing support
Date: Thu, 13 Aug 2015 21:15:22 -0700 (PDT)
Message-ID: <20150813.211522.338072408198434671.davem@davemloft.net>
References: <1439439262-27980-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbbHNEPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 00:15:23 -0400
In-Reply-To: <1439439262-27980-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 13 Aug 2015 09:44:22 +0530

> Handle TRACE_PKT, stack can sniff them on the first port
> Add debubfs enrty to configure tracing for offload traffic like iWARP
> & iSCSI for debugging purpose.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
