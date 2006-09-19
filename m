From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig
Date: Tue, 19 Sep 2006 08:29:11 -0700
Message-ID: <20060919082911.46828a25@localhost.localdomain>
References: <20060918095936.GA6161@outpost.ds9a.nl>
	<20060918195224.GA26585@outpost.ds9a.nl>
	<20060918214104.3824a2e2@localhost.localdomain>
	<200609191203.51045.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bert hubert <bert.hubert@netherlabs.nl>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30359 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751210AbWISP37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 11:29:59 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200609191203.51045.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Sep 2006 12:03:51 +0200
Andi Kleen <ak@suse.de> wrote:

> On Tuesday 19 September 2006 06:41, Stephen Hemminger wrote:
> > Bert's attempt was noble
> > It showed your desire for the truth
> > A simple path exists
> 
> I guess most people won't have a clue on what to configure here
> (especially with such sparse help text, but even with more 
> it would be hard). 
> 
> And you might end up with some weird error reports if someone
> manages to configure one of the more broken algorithms.
> 

I tried to only put known stable ones in the choices list.
