From: David Dillow <dave@thedillows.org>
Subject: Re: network card with inline crypto engine?
Date: Tue, 19 Aug 2008 13:51:39 -0400
Message-ID: <1219168299.15135.15.camel@lap75545.ornl.gov>
References: <804fd2027cd558087a3db013b9ec80af@91.121.53.53>
	 <20080819.015036.223405950.davem@davemloft.net>
	 <335b1a8e57d24608fae99045a49cb70b@91.121.53.53>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jean-Christophe DUBOIS <jcd@tribudubois.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lap75545.ornl.gov ([160.91.210.54]:60615 "EHLO
	lap75545.ornl.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbYHSSsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 14:48:37 -0400
In-Reply-To: <335b1a8e57d24608fae99045a49cb70b@91.121.53.53>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-08-19 at 16:38 +0200, Jean-Christophe DUBOIS wrote:
> Thanks Dave,
> 
> I guess you are refering to this proposal:
> 
> http://oss.sgi.com/archives/netdev/2005-01/msg00347.html
> 
> And nothing is in the plan at the moment?

I assume that's the one he's referring to. I started reworking it, but
then life intervened. I'd like to finish it off, but it seems somewhat
pointless now with the Typhoon cards.

I'd differ on the usable, but he's right it wasn't the cleanest
possible.
