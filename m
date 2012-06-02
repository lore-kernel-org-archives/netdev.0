From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 0/7] Generic netdev features support
Date: Sat, 2 Jun 2012 02:31:36 +0100
Message-ID: <1338600696.2770.27.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120601174517.100bf98f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57902 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966163Ab2FBBbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 21:31:40 -0400
In-Reply-To: <20120601174517.100bf98f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-01 at 17:45 -0700, Stephen Hemminger wrote:
> On Sat, 2 Jun 2012 01:33:47 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > This series adds support for the not-so-new generic netdev features
> > ethtool API, along with some test infrastructure and test cases to check
> > that it works with old and new kernel versions.  I'm still not convinced
> > that there are enough test cases, but I've held this back for too damn
> > long already.
> > 
> > I'd like to include these changes in an ethtool 3.4 release by the end
> > of next week, so let me know if there's anything wrong with them.
> > 
> > Ben.
> 
> Slightly off-topic, is anyone working on doing ethtool setting over netlink?

I'm not.  I seem to remember you brought this up at netconf 2010 but I
don't remember what your motivation was.  Were you thinking about being
able to monitor for changes, for example?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
