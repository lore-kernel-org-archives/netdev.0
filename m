From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] net: ethernet: davicom: Allow to select DM9000 for
 nios2
Date: Fri, 12 Dec 2014 22:58:16 +0900
Message-ID: <20141212135810.GA20858@verge.net.au>
References: <1418376071-28709-1-git-send-email-tklauser@distanz.ch>
 <20141212112842.GA17780@verge.net.au>
 <20141212124015.GH16916@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60441 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968285AbaLLN6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 08:58:20 -0500
Content-Disposition: inline
In-Reply-To: <20141212124015.GH16916@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 01:40:15PM +0100, Tobias Klauser wrote:
> On 2014-12-12 at 12:28:42 +0100, Simon Horman <horms@verge.net.au> wrote:
> > On Fri, Dec 12, 2014 at 10:21:11AM +0100, Tobias Klauser wrote:
> > > This chip is present on older revisions of the DE2 development kit.
> > > 
> > > Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> > 
> > I wonder if || COMPILE_TEST should also be added to allow extra build
> > coverage. Is there a specific reason it won't compile more widely?
> > 
> > Likewise for your smsc patch.
> 
> Good point. I don't think there's a reason for it not being compiled
> more widely. Should I update my patches accordingly or send a separate
> patch?

I'm not the maintainer but a follow-up patch or patches seems reasonable to me.
