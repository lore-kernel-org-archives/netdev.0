From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Fix leak when recycling skb and hypervisor
 returns error
Date: Wed, 24 Aug 2011 17:56:32 -0700 (PDT)
Message-ID: <20110824.175632.593843178865523416.davem@davemloft.net>
References: <20110825092019.777aea6e@kryten>
	<20110824.174353.1962229766905714384.davem@davemloft.net>
	<20110825105520.5ba7ae90@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab1HYA4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 20:56:36 -0400
In-Reply-To: <20110825105520.5ba7ae90@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Thu, 25 Aug 2011 10:55:20 +1000

>> Please generate this patch against Linus's tree, instead of -next
> 
> Sure, here it is.

Applied, thanks.
