From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
 regression
Date: Tue, 27 Jul 2010 08:09:21 -0700
Message-ID: <20100727150921.GD5803@kroah.com>
References: <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
 <1279822828.12439.24.camel@jlt3.sipsolutions.net>
 <20100722182827.GA12821@suse.de>
 <1279823801.12439.31.camel@jlt3.sipsolutions.net>
 <20100722185449.GB528@suse.de>
 <m1eievugon.fsf@fess.ebiederm.org>
 <20100726180941.GB4883@kroah.com>
 <AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
 <20100727134904.GA4994@kroah.com>
 <1280239190.3755.4.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:44367 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756468Ab0G0PJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 11:09:25 -0400
Content-Disposition: inline
In-Reply-To: <1280239190.3755.4.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 03:59:50PM +0200, Johannes Berg wrote:
> On Tue, 2010-07-27 at 06:49 -0700, Greg KH wrote:
> 
> > And Eric, where are you working on the "real" patches to solve the
> > problems of the bnet and wireless driver problems so we can remove this
> > check from the driver core as soon as possible?  Any idea when they will
> > be done?
> 
> They'll be done as soon as the driver core offers the required
> functionality, which we discussed elsewhere in this thread.

{sigh}

Kay provided a solution for this a number of times already.  What, are
you really going to make him type it up _again_?  That's just completly
unfair to him.

And note, Eric, this was and is, completely due to your changes, so I am
holding you responsible for fixing it correctly.  Please do so.

greg k-h
