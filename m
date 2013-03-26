From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next (TAKE 4) 0/6] IPv6 over Firewire
Date: Tue, 26 Mar 2013 12:32:59 -0400 (EDT)
Message-ID: <20130326.123259.353351738581905875.davem@davemloft.net>
References: <51509696.6060600@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefanr@s5r6.in-berlin.de, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net, stephan.gatzka@gmail.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934635Ab3CZQdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:33:02 -0400
In-Reply-To: <51509696.6060600@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 26 Mar 2013 03:25:26 +0900

> This is take 4 of supporting IPv6 over Firewire (IEEE 1394) based on
> RFC3146.
> 
> Take 3->4:
> - Fix receiving 1394 ARP, which comes without arp$tha.
> - Remove rfc3146 unit directory on module exit.
> - other minor clean-ups - minimize diffs.

Series applied, thanks.
