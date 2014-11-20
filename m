From: David Miller <davem@davemloft.net>
Subject: Re: Translation table available between 'ethtool -k' and 'ethtool
 -K' ? For Linux?
Date: Thu, 20 Nov 2014 18:35:35 -0500 (EST)
Message-ID: <20141120.183535.187100838408500538.davem@davemloft.net>
References: <BABF60987D48764FA4071AC73CB9C56162EBFBD0AC@AUSX7MCPC101.AMER.DELL.COM>
	<1416526354.7215.4.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Spike_White@Dell.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756600AbaKTXfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 18:35:37 -0500
In-Reply-To: <1416526354.7215.4.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 20 Nov 2014 23:32:34 +0000

> So instead of properly validating drivers, you just assume they all have
> the same bug as something you saw in the past?
> 
> You may think you're being conservative, but by using non-default
> settings you're actually taking more of a risk.

+1
