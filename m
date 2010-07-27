From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
 regression
Date: Tue, 27 Jul 2010 15:59:50 +0200
Message-ID: <1280239190.3755.4.camel@jlt3.sipsolutions.net>
References: <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
	 <m1vd87toy9.fsf@fess.ebiederm.org>
	 <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
	 <1279822828.12439.24.camel@jlt3.sipsolutions.net>
	 <20100722182827.GA12821@suse.de>
	 <1279823801.12439.31.camel@jlt3.sipsolutions.net>
	 <20100722185449.GB528@suse.de> <m1eievugon.fsf@fess.ebiederm.org>
	 <20100726180941.GB4883@kroah.com>
	 <AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	 <20100727134904.GA4994@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:35231 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755993Ab0G0OAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 10:00:34 -0400
In-Reply-To: <20100727134904.GA4994@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-07-27 at 06:49 -0700, Greg KH wrote:

> And Eric, where are you working on the "real" patches to solve the
> problems of the bnet and wireless driver problems so we can remove this
> check from the driver core as soon as possible?  Any idea when they will
> be done?

They'll be done as soon as the driver core offers the required
functionality, which we discussed elsewhere in this thread.

johannes

