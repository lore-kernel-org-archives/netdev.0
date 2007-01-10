From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Wed, 10 Jan 2007 14:31:51 +0100
Message-ID: <20070110133151.GA4013@ff.dom.local>
References: <20070108132548.GA2324@ff.dom.local> <200701090926.47206.paul.moore@hp.com> <20070110100145.GA2611@ff.dom.local> <200701100813.57939.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:44347 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932596AbXAJN36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 08:29:58 -0500
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <200701100813.57939.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 08:13:57AM -0500, Paul Moore wrote:
> On Wednesday 10 January 2007 5:01 am, Jarek Poplawski wrote:
> > On Tue, Jan 09, 2007 at 09:26:46AM -0500, Paul Moore wrote:
> > > On Tuesday 09 January 2007 3:43 am, Jarek Poplawski wrote:
> > > > ... But if you consider this code will probably become classical
> > > > and will be read, quoted and teached next 1000 years, then the style
> > > > could matter...
> > >
> > > This from the guy who believes "Justin Timberlake rocks!" ;)
> > >
> > > All right, you convinced me, I'll send out a patch to the patch later
> > > today.
> >
> > I'm terribly sorry, I didn't expected any messing now!
> > I rather thought about some preferences for the future.
> 
> No need to apologize, it was a trivial fix and I figured I might as well take 
> care of now ... however, some of your taste in music does require an 
> apology ;)

All right, you convinced me too. I change 50 Cent to Busta Rhymes!

Jarek P.  
