From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [GIT]: Networking
Date: Fri, 09 May 2008 10:32:14 -0400
Message-ID: <4824606E.3040409@garzik.org>
References: <20080508.171408.94456716.davem@davemloft.net> <alpine.LFD.1.10.0805081848170.2940@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49124 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401AbYEIOcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2008 10:32:18 -0400
In-Reply-To: <alpine.LFD.1.10.0805081848170.2940@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds wrote:
> It's one thing taking a totally new driver (that couldn't have worked 
> before and cannot be a regression) or adding new PCI ID's. It's a totally 
> different thing to take 800 lines of code to an old driver that people 
> depend on. These things need to happen during the merge window, and just 
> because they are drivers doesn't mean that they can just do anythign they 
> want.

The e1000e change is just a bunch of code additions for a new phy type, 
not a bunch of /changes/ really.  Is that the change you're concerned with?

	Jeff



