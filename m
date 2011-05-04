From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Support e1000 M88 PHY registers in -d
Date: Wed, 04 May 2011 18:41:15 +0100
Message-ID: <1304530875.2926.29.camel@bwh-desktop>
References: <20100319043229.24908.99968.reportbug@Feynman.home>
	 <1301761441.10056.197.camel@localhost>
	 <BANLkTik7G82DwhA_EU8KrKJO25+W=yjWFg@mail.gmail.com>
	 <1301910102.2935.52.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anthony DeRobertis <anthony@derobert.net>,
	netdev <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, 574574@bugs.debian.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:10454 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929Ab1EDRlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:41:19 -0400
In-Reply-To: <1301910102.2935.52.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-04 at 10:41 +0100, Ben Hutchings wrote:
> On Mon, 2011-04-04 at 01:36 -0700, Jeff Kirsher wrote:
> > On Sat, Apr 2, 2011 at 09:24, Ben Hutchings <bhutchings@solarflare.com> wrote:
> > > Anthony,
> > >
> > > I'm now upstream maintainer for ethtool so I've picked up your patch
> > > again.
> > >
> > > On Fri, 2010-03-19 at 00:32 -0400, Anthony DeRobertis wrote:
> > >> Package: ethtool
> > >> Version: 1:2.6.33-1
> > >> Severity: wishlist
> > >>
> > >> The M88 PHY registers contain useful information like the cable length
> > >> estimate and the MDI/MDIX status. The attached patch makes -d dump
> > >> them.
> > >
> > > Patches for ethtool should include a commit message and Signed-off-by
> > > line, as in the Linux kernel.  See sections 2 and 12 of
> > > <http://www.kernel.org/doc/Documentation/SubmittingPatches>.  They
> > > should be sent to this address and to netdev.
> > >
> > > I'm forwarding this patch to netdev and the e1000 developers for review.
> > >
> > > Ben.
> > 
> > Thanks Ben.  Just to be clear, have you applied these e1000 changes to
> > the ethtool?
> [...]
> 
> I have not applied these changes either anywhere.

...but I will if I don't hear back from you soon.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

