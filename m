From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: make user modified path cost sticky
Date: Mon, 15 Apr 2013 14:05:04 -0400 (EDT)
Message-ID: <20130415.140504.612756635505590698.davem@davemloft.net>
References: <20130413170607.2a9294f6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019Ab3DOSFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 14:05:06 -0400
In-Reply-To: <20130413170607.2a9294f6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 13 Apr 2013 17:06:07 -0700

> Keep a STP port path cost value if it was set by a user.
> Don't replace it with the link-speed based path cost
> whenever the link goes down and comes back up.
> 
> Reported-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks.
