From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice: document NETDEV_TX_BUSY
 deprecation.
Date: Fri, 03 Apr 2015 12:37:53 -0400 (EDT)
Message-ID: <20150403.123753.1902372072873141931.davem@davemloft.net>
References: <20150402125743-mutt-send-email-mst@redhat.com>
	<87pp7l5t8a.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, stephen@networkplumber.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbbDCQhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 12:37:54 -0400
In-Reply-To: <87pp7l5t8a.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 03 Apr 2015 22:17:17 +1030

> This paraphrases DaveM (and steals some of his words) explaining why
> a device shouldn't return NETDEV_TX_BUSY, even though it looks so inviting
> to driver authors.
> 
> See http://www.spinics.net/lists/netdev/msg322350.html
> 
> Inspired-by: David Miller <davem@davemloft.net>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied.
