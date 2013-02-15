From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: bonding inactive slaves vs rx_dropped
Date: Fri, 15 Feb 2013 17:47:50 +0000
Message-ID: <1360950470.3192.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130214.160657.1394358701071068786.davem@davemloft.net>
	 <4606.1360878661@death.nxdomain>
	 <20130214.171821.186191007478674738.davem@davemloft.net>
	 <6330.1360885388@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>, <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63733 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349Ab3BORrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 12:47:53 -0500
In-Reply-To: <6330.1360885388@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 15:43 -0800, Jay Vosburgh wrote:
> David Miller <davem@davemloft.net> wrote:
[...]
> >My general rule is that every special case increments a special
> >'absurdity' statistic counter for the code :-)
> 
> 	Gonna need a whole lot of those for bonding, then.  Maybe it
> should have its own ethtool -S stats to handle all of the
> bonding-internal absurdity.
[...]

Yes, I think it should.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
