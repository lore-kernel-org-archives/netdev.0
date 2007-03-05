From: Matt Mackall <mpm@selenic.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 15:14:25 -0600
Message-ID: <20070305211425.GR16722@waste.org>
References: <20070304220857.GH23311@waste.org> <20070305011625.GA7681@kroah.com> <20070305064229.GJ23311@waste.org> <20070305070248.GA30699@kroah.com> <20070305071325.GK23311@waste.org> <20070305154609.GA3626@irc.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, greg@kroah.com,
	netdev@vger.kernel.org, yi.zhu@intel.com, jketreno@linux.intel.com,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:45870 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933610AbXCEV1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 16:27:30 -0500
Content-Disposition: inline
In-Reply-To: <20070305154609.GA3626@irc.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 04:46:09PM +0100, Tomasz Torcz wrote:
> > That's not the point. The point is that Debian/unstable as of _this
> > morning_ doesn't work. For reference, I'm running both the latest
> > releases of both hal (0.5.8.1-6.1) and network-manager (0.6.4-6). And
> > there are people telling me I need a copy of HAL out of git that
> > hasn't even been released for Debian to package. Debian isn't the
> > problem here.
> 
>   hal 0.5.9-rc1 (released, not from git) should work. It will be
> problably released soon and picked by sane distributions. Debian is very
> irritating corner case.

Presumably the -rc1 stands for "release candidate". Which means "not
yet released". And when did it show up? 04-Mar-2007 at 18:31. That's
right, YESTERDAY. Almost a full month after Greg's commit.

For the last time, DEBIAN IS NOT THE PROBLEM.

-- 
Mathematics is the supreme nostalgia of our time.
