From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: group address list and its count
Date: Wed, 17 Jun 2009 19:03:58 -0700 (PDT)
Message-ID: <20090617.190358.95208276.davem@davemloft.net>
References: <20090617111218.GB3834@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50546
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755715AbZFRCDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:03:54 -0400
In-Reply-To: <20090617111218.GB3834@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 17 Jun 2009 13:12:19 +0200

> [PATCH net-next] net: group address list and its count
> 
> This patch is inspired by patch recently posted by Johannes Berg. Basically what
> my patch does is to group list and a count of addresses into newly introduced
> structure netdev_hw_addr_list. This brings us two benefits:
> 1) struct net_device becames a bit nicer.
> 2) in the future there will be a possibility to operate with lists independently
>    on netdevices (with exporting right functions).
> I wanted to introduce this patch before I'll post a multicast lists conversion.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

I like this a lot, applied, thanks Jiri.
