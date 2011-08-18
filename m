From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] bonding: use ndo_change_rx_flags callback
Date: Wed, 17 Aug 2011 20:18:19 -0700 (PDT)
Message-ID: <20110817.201819.1669797322877369204.davem@davemloft.net>
References: <1313487050-4048-1-git-send-email-jpirko@redhat.com>
	<CAHXqBFJL+y3TOj-OX4wXT-H1Z9R3EqJLnA64t5_ocCKLx6tPUQ@mail.gmail.com>
	<20110816131503.GA26958@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001Ab1HRDS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 23:18:26 -0400
In-Reply-To: <20110816131503.GA26958@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 16 Aug 2011 15:15:04 +0200

> V2:
> 
> Subject: [patch net-next-2.6 v2] bonding: use ndo_change_rx_flags callback
> 
> Benefit from use of ndo_change_rx_flags in handling change of promisc
> and allmulti. No need to store previous state locally.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> v1->v2: fixed IFF_ALLMULTI/IFF_PROMISC c&p typo

Applied, thanks.
