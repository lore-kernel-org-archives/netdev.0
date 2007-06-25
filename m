From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK]: Add nested compat attribute
Date: Mon, 25 Jun 2007 14:32:48 -0700 (PDT)
Message-ID: <20070625.143248.73361950.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC32903179937@orsmsx414.amr.corp.intel.com>
	<20070625.135047.124049631.davem@davemloft.net>
	<46802EB9.506@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41334
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751885AbXFYVca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 17:32:30 -0400
In-Reply-To: <46802EB9.506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 25 Jun 2007 23:08:09 +0200

> David Miller wrote:
> >
> >> I've been using this patch and the IPROUTE2 patches Patrick has proposed
> >> with no issues.  Can someone else look at these patches when they have
> >> time?  I'd be interested in seeing them make it into 2.6.23.
> >>     
> >
> > I've just put Patrick's patch into the net-2.6.23 tree.
> >   
> 
> You seem to have added the netlink patch for the generic
> netlink attributes. Peter needs the rtnetlink attribute
> patch since qdiscs still use the old stuff.
> 
> Attached again to this mail.

Thanks for the clarification, I thought they were both the
same patch, resent for the sake of tgraf seeing it.

I've applied this one too, thanks Patrick.
