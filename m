From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Increase MDIO timeouts
Date: Sat, 26 Apr 2008 13:35:13 +1000
Message-ID: <1209180913.5420.37.camel@pasglop>
References: <20080423051832.63BF7DDF65@ozlabs.org>
	 <20080425165703.864e63bd.billfink@mindspring.com>
	 <1209162158.5420.35.camel@pasglop>
	 <20080425185842.7ab463e7@zod.rchland.ibm.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>,
	super.firetwister@googlemail.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43044 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753860AbYDZDgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 23:36:37 -0400
In-Reply-To: <20080425185842.7ab463e7@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-04-25 at 18:58 -0500, Josh Boyer wrote:
> > > I guess them being "two short" is why they needed to be
> doubled.  :-)
> > 
> > Well, in that case, it makes sense, it's still pretty short and
> better
> > safe than sorry. On day I may look at actually measuring PHYs and
> see if
> > it's worth trying to do sleeping waits in there.
> 
> I think you missed Bill's joke.  Read your original email and spot the
> typo, then read Bill's pun.
> 
> And stop emailing before you eat breakfast ;)

Hrm ... yeah allright I missed my initial typo and I missed Bill
joke :-) looks like another case of replying while still half asleep ...

Ben.


