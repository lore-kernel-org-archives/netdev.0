From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: cleanup skb_set_hash
Date: Thu, 19 Dec 2013 19:16:53 -0500 (EST)
Message-ID: <20131219.191653.1876082892020900047.davem@davemloft.net>
References: <alpine.DEB.2.02.1312190856320.8092@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516Ab3LTAQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:16:55 -0500
In-Reply-To: <alpine.DEB.2.02.1312190856320.8092@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 19 Dec 2013 08:59:08 -0800 (PST)

> Save pkt_hash_types in tpa structure.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Looks good, applied to net-next, thanks.
