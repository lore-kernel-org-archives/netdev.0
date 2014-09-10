From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next v2 0/2] sunvnet: Reduce LDC message overhead.
Date: Wed, 10 Sep 2014 18:37:22 -0400
Message-ID: <20140910223722.GH14466@oracle.com>
References: <20140904.223724.206826043871814498.davem@davemloft.net>
 <20140908143802.GF31377@oracle.com>
 <20140910140434.GA14466@oracle.com>
 <20140910.152528.391406680350942661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43477 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaIJWh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 18:37:27 -0400
Content-Disposition: inline
In-Reply-To: <20140910.152528.391406680350942661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/10/14 15:25), David Miller wrote:
> 
> After the memory barrier stuff has been sorted out, the patches
> should be submitted again for review.
> 
> But I was under the impression that for now we weren't going to
> be doing the new udelay() things, which defers patch #2 for now.

ah, ok, I didn't realize the ball was in my court- good that I checked.

I'll re-submit a unified diff without the extra-udelay-stuff
as a v3 patch for review tomorrow.

--Sowmini
