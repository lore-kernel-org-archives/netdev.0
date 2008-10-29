From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] macvlan: propogate mtu changes
Date: Wed, 29 Oct 2008 14:05:22 -0700 (PDT)
Message-ID: <20081029.140522.29966751.davem@davemloft.net>
References: <20081029125912.002dbe9d@extreme>
	<4908CF66.3030802@trash.net>
	<4908CFFE.5000501@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753654AbYJ2VFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:05:47 -0400
In-Reply-To: <4908CFFE.5000501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 29 Oct 2008 22:05:02 +0100

> Patrick McHardy wrote:
> > Stephen Hemminger wrote:
> >   
> >> If MTU of underlying real device is changed, propogate up to macvlan
> >> pseudo devices.
> >>     
> >
> > I'm going to do a similar patch for macvlan as I did for VLAN for
> > the MTU settings (desired MTU/operational MTU).
> 
> ... and add the rollback part from your patch to VLAN as well.

So you want me to drop this second patch from Stephen from now?
