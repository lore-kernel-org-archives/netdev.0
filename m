From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next v2 0/2] sunvnet: Reduce LDC message overhead.
Date: Wed, 10 Sep 2014 10:04:34 -0400
Message-ID: <20140910140434.GA14466@oracle.com>
References: <20140902161936.GA31516@oracle.com>
 <20140904.223724.206826043871814498.davem@davemloft.net>
 <20140908143802.GF31377@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42327 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbaIJOEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 10:04:42 -0400
Content-Disposition: inline
In-Reply-To: <20140908143802.GF31377@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Excuse me if I am missing something obvious, but what was the 
verdict on this? Is there any additional clarification/information 
I can provide, if this is being mulled over? 

--Sowmini

On (09/08/14 10:38), Sowmini Varadhan wrote:
> 
> On (09/04/14 22:37), David Miller wrote:
> > 
> > From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> > 
> > > This patchset has an updated version of the v1 changes to reduce the
> > > overhead from LDC messages. 
> > 
> > Let's hold on these changes until the memory barrier issues brought up
> > by David is resolved.
> 
> On (09/07/14 16:19), David Miller wrote (in the patch 2/2 thread for this set):
> > 
> > > So what (if any) is the outstanding question about wmb() at this 
> > > point?
> > 
> > I don't think there is any, thanks.
> 
> I'm not sure where we stand with this- do I need to resubmit any/all of 
> those two patches?
> 
> --Sowmini
