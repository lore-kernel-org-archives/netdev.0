From: Greg Lindahl <greg@blekko.com>
Subject: Re: Treason uncloaked / Broken peer again
Date: Fri, 27 Feb 2009 13:27:19 -0800
Message-ID: <20090227212719.GD25573@bx9.net>
References: <20090226085826.GA12498@gondor.apana.org.au> <Pine.LNX.4.64.0902261105030.31742@wrl-59.cs.helsinki.fi> <20090227212234.GB25573@bx9.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rc.bx9.net ([64.13.160.15]:44620 "EHLO rc.bx9.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755979AbZB0V1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 16:27:21 -0500
Content-Disposition: inline
In-Reply-To: <20090227212234.GB25573@bx9.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 01:22:34PM -0800, Greg Lindahl wrote:

> One of the people who complained to me is running 2.4.26, so the bug
> in TSO that you fixed in 2.6.25 is not the last bug at issue.

Sorry, I was confused, he really did say 2.4.26, so it's really old.

But, my experiment turning off TSO on 2.6.18+redhat shows that the
TSO bug fixed in 2.6.25 isn't the only bug.

> I was
> also able to turn off TSO on all my 2.6.18+redhat systems and quickly
> got Treason, so this bug is not the only one. But still, I can't cause
> the bug often enough to get a tcpdump of it in action.

-- greg
