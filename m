From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 1/3] TIPC: Removing EXPERIMENTAL label
Date: Fri, 25 May 2012 15:05:06 -0400
Message-ID: <20120525190506.GB25102@windriver.com>
References: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
 <20120521.023926.548567931208958037.davem@davemloft.net>
 <20120524195816.GA6487@windriver.com>
 <20120524.161231.1058511318935925082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <jon.maloy@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>, <ying.xue@windriver.com>,
	<erik.hugne@ericsson.com>, <allan.stephens@windriver.com>,
	<maloy@donjonn.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:53239 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467Ab2EYTFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 15:05:21 -0400
Content-Disposition: inline
In-Reply-To: <20120524.161231.1058511318935925082.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH 1/3] TIPC: Removing EXPERIMENTAL label] On 24/05/2012 (Thu 16:12) David Miller wrote:

> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Thu, 24 May 2012 15:58:16 -0400
> 
> > But for new TIPC development features, future direction, and things like
> > that -- making the right call requires intimate understanding of TIPC
> > and its users, which is something that a maintainer should have but
> > something I know I don't have.  (A man has to know his limitations.)
> > 
> > In this context, I'm not talking about these three trivial patches; but
> > more complicated stuff that I imagine will be floated in the future.
> > 
> > To that end, I can still review and call out issues in a crap patch when
> > I see them.  But I'd like to see new stuff sent to netdev, so that folks
> > smarter than me have a chance to catch when a patch appears generally OK
> > but is architecturally the wrong direction etc.
> 
> For maintainership, taste is more important than deep knowledge of the
> specific technology.  Worst case you ask the submitter to explain the
> background of their change more thoroughly and that information is an
> absolutely requirement in the commit message and code comments
> anyways.

OK, what I'm hearing is that you'd prefer I continue to collect up TIPC
patches and issue pull requests for a while longer.  I can do that.  Any
specifics of how you'd like things done? -- e.g. if the reviews of new
TIPC development patches takes place here on netdev before I stage them,
will that create extra work for you dealing with them in patchworks?

Paul.
