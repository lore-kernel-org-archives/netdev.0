From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: Re: /128 link-local subnet on 6in4 (sit) tunnels?
Date: Wed, 27 Mar 2013 20:12:51 +0100
Message-ID: <1364411571.15362.8.camel@localhost>
References: <1364335457.8215.21.camel@localhost>
	 <20130327151210.GA23223@order.stressinduktion.org>
	 <1364398673.21709.4.camel@localhost>
	 <20130327181146.GB23223@order.stressinduktion.org>
	 <1364408454.15362.1.camel@localhost>
	 <20130327183558.GC23223@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 37-251-2-65.FTTH.ispfabriek.nl ([37.251.2.65]:55575 "EHLO
	mail.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab3C0TMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 15:12:53 -0400
In-Reply-To: <20130327183558.GC23223@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 19:35 +0100, Hannes Frederic Sowa wrote:
> On Wed, Mar 27, 2013 at 07:20:54PM +0100, Wilco Baan Hofman wrote:
> > http://tools.ietf.org/html/rfc4213
> 
> Thanks, I have seen that already. The sit driver is used for more than 6in4
> (6to4, isatap, 6rd). So such a change has to be ok with all the other
> protocols implemented by sit. I also looked in the historic git archive for a
> rationale of this but couldn't find one. Commit messages 2002 where not as
> descriptive as today("Import changeset"). :)
> 
> I also added YOSHIFUJI Hideaki as Cc, perhaps he knows the reason.

Fair enough, I sort of expected a comment to be there as to why it would
be a /128 as well.. :)

-- Wilco
