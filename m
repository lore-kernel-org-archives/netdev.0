From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] IPv6: Fix infinite loop if no matching IPv6 tunnel
 found
Date: Fri, 24 Nov 2006 17:12:42 -0800 (PST)
Message-ID: <20061124.171242.52164245.davem@davemloft.net>
References: <4549FF0F.6020705@tcs.hut.fi>
	<20061113.165716.26277561.davem@davemloft.net>
	<4559C1B4.4010609@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:24725
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S935106AbWKYBMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 20:12:32 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <4559C1B4.4010609@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Tue, 14 Nov 2006 15:16:36 +0200

> David Miller wrote:
> > From: Ville Nuorvala <vnuorval@tcs.hut.fi>
> > Date: Thu, 02 Nov 2006 16:22:07 +0200
> > 
> >> Ok, I'll resubmit a patch doesn't send an ICMPv6 error message.
> > 
> > Is this coming soon?  I'd like to integrate this patch set into
> > net-2.6.20 if I can.
> 
> No, it was a false alarm as Herbert's patch already addressed the problem.

So I applied patches 1 to 5 to net-2.6.20, and did not apply patch 6.

Thanks!
