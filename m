From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: show offload settings
Date: Fri, 15 Aug 2008 19:56:52 -0700 (PDT)
Message-ID: <20080815.195652.179231294.davem@davemloft.net>
References: <20080815100259.12c8175a@extreme>
	<20080815.145118.198768799.davem@davemloft.net>
	<10558.1218841183@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43744
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751019AbYHPC4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 22:56:53 -0400
In-Reply-To: <10558.1218841183@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 15 Aug 2008 15:59:43 -0700

> David Miller <davem@davemloft.net> wrote:
> 
> >From: Stephen Hemminger <shemminger@vyatta.com>
> >Date: Fri, 15 Aug 2008 10:02:59 -0700
> >
> >> Add more ethtool generic operations to dump the bridge offload
> >> settings.
> >> 
> >> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> >Applied, thanks.
> 
> 	I might be confused, but it looks like Stephen included the
> wrong patch; it references "bridge" in the comments, but duplicates his
> earlier patch for bonding:

This has been sorted out, thanks Jay.
