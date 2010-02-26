From: David Miller <davem@davemloft.net>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Thu, 25 Feb 2010 21:53:57 -0800 (PST)
Message-ID: <20100225.215357.140469725.davem@davemloft.net>
References: <4B85F173.40703@garzik.org>
	<Pine.WNT.4.64.1002251739130.51452@ppwaskie-MOBL2.amr.corp.intel.com>
	<4B87315E.4080905@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42138
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752453Ab0BZFxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 00:53:39 -0500
In-Reply-To: <4B87315E.4080905@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 25 Feb 2010 21:26:38 -0500

> On 02/25/2010 08:49 PM, Waskiewicz Jr, Peter P wrote:
>> This will require a small kernel change.  Will something like this be
>> pulled in at this point, given that 2.6.33 just released?
> 
> The n-tuple stuff is not in 2.6.33's ethtool interface, so it hasn't
> actually made it into a released kernel at this point.
> 
> It seems reasonable for 2.6.34 to either add ETHTOOL_GSTRINGS_COUNT or
> update drvinfo.  Even if net-next has already been pulled into
> post-2.6.33 merge window, that would IMO qualify as a reasonable
> interface bugfix to get upstream.  The ethtool n-tuple ABI is not
> locked into stone until 2.6.34 is released by Linus.

Right.
