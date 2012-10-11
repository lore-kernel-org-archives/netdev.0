From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2 2/5] pktgen: set different default min_pkt_size for
 different protocols
Date: Wed, 10 Oct 2012 22:34:02 -0400 (EDT)
Message-ID: <20121010.223402.1524279301354018295.davem@davemloft.net>
References: <1349840900-24138-1-git-send-email-amwang@redhat.com>
	<1349840900-24138-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159Ab2JKCeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 22:34:03 -0400
In-Reply-To: <1349840900-24138-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 10 Oct 2012 11:48:17 +0800

> ETH_ZLEN is too small for IPv6, so this default value is not
> suitable.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
