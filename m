From: Heikki Orsila <shdl@zakalwe.fi>
Subject: Re: net: skge breakage on 2.6.24-rc1
Date: Thu, 8 Nov 2007 01:13:21 +0200
Message-ID: <20071107231321.GE8865@zakalwe.fi>
References: <20071107214621.GA8865@zakalwe.fi> <20071107215348.GB8865@zakalwe.fi> <200711072350.30645.rjw@sisk.pl> <20071107150621.f2da7f69.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759878AbXKGXNc@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071107150621.f2da7f69.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 03:06:21PM -0800, Andrew Morton wrote:
> > On Wed, 7 Nov 2007 23:50:30 +0100 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > On Wednesday, 7 of November 2007, Heikki Orsila wrote:
> > > On Wed, Nov 07, 2007 at 11:46:21PM +0200, Heikki Orsila wrote:
> > > > After some bisecting, I found that net skge driver broke on
> > > > 
> > > > commit 7fb7ac241162dc51ec0f7644d4a97b2855213c32
> 
> 
> Thanks for doing the bisection.  It's a good idea to cc the author of the
> offending patch after having done this.

Sorry, I just forgot this time. Just after the bug report I did mail 
the author in private (out of the list).

-- 
Heikki Orsila			Barbie's law:
heikki.orsila@iki.fi		"Math is hard, let's go shopping!"
http://www.iki.fi/shd
