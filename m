From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-timestamp: Update skb_complete_tx_timestamp comment
Date: Mon, 10 Aug 2015 13:35:57 -0700 (PDT)
Message-ID: <20150810.133557.1178147999990755832.davem@davemloft.net>
References: <1438965141-26099-1-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@redhat.com
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932453AbbHJUf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 16:35:58 -0400
In-Reply-To: <1438965141-26099-1-git-send-email-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Fri,  7 Aug 2015 09:32:21 -0700

> After "62bccb8 net-timestamp: Make the clone operation stand-alone from phy
> timestamping" the hwtstamps parameter of skb_complete_tx_timestamp() may no
> longer be NULL.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> Cc: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied, thank you.
