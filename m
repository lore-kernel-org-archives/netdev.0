From: Paul Smith <paul@mad-scientist.us>
Subject: Re: Any implementation of NETPOLL for bonding?
Date: Tue, 23 Jun 2009 13:01:00 -0400
Message-ID: <1245776460.9022.19.camel@psmith-ubeta.netezza.com>
References: <1245101162.11148.210.camel@psmith-ubeta.netezza.com>
	 <20090615230907.GA8515@gospo.rdu.redhat.com>
	 <1245165201.11148.244.camel@psmith-ubeta.netezza.com>
Reply-To: paul@mad-scientist.us
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta.netezza.com ([12.148.248.132]:49911 "EHLO netezza.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751071AbZFWRQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2009 13:16:23 -0400
In-Reply-To: <1245165201.11148.244.camel@psmith-ubeta.netezza.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-06-16 at 11:13 -0400, Paul Smith wrote:
> On Mon, 2009-06-15 at 19:09 -0400, Andy Gospodarek wrote:
> > On Mon, Jun 15, 2009 at 05:26:02PM -0400, Paul Smith wrote:
> > > I wanted to attach to my kernel with KGDBOE but failed because the
> > > bonding driver doesn't support NETPOLL, and the only network access to
> > > the system is over a bonded interface.
> > 
> > I did some work in the not-too-distant past on this and can probably
> > dig-up the patches and port them to the latest upstream.  Would you be
> > able to test a patch?

Hi Andy; did you have any time to dig these out and forward them to me?
I'm happy to test them for you.

Thanks!

