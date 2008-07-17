From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/20] mib: add struct net to IP, TCP and NET macros
Date: Wed, 16 Jul 2008 20:38:54 -0700 (PDT)
Message-ID: <20080716.203854.08602318.davem@davemloft.net>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43919
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754277AbYGQDiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 23:38:55 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 16 Jul 2008 12:05:10 +0400

> This is actually the last very scattered set, that changes many calls
> to MIB accounting macros. What is left requires less patching.
> 
> David, I hope this (and a finalizing set, I will prepare after this
> one is accepted) can go to current 2.6.27 merge window, but it is OK
> with me if your decision is to delay this till 2.6.28.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Ok, all applied to net-next-2.6, I'll push after I do some build
testing.

Patch 19 is ugly :(  But I can't recommend another approach.
If you could find a way to clean that stuff up, it would
really be appreciated.

If you can get your "finalizing set" to me today or tomorrow,
I guess I can apply it.

I plan to merge net-next to Linus either Sunday or Monday.
