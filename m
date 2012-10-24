From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 2/8] maintainers: update with official intel support
 link, new maintainer
Date: Tue, 23 Oct 2012 21:52:35 -0700
Message-ID: <1351054355.7502.102.camel@joe-AO722>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350987887-16161-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1350998701.7502.42.camel@joe-AO722>
	 <1351053166.2252.39.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tushar Dave <tushar.n.dave@intel.com>, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38053 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750802Ab2JXEwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 00:52:36 -0400
In-Reply-To: <1351053166.2252.39.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-23 at 21:32 -0700, Jeff Kirsher wrote:
> On Tue, 2012-10-23 at 06:25 -0700, Joe Perches wrote:
> > On Tue, 2012-10-23 at 03:24 -0700, Jeff Kirsher wrote:

> > > Add the current e1000 maintainer to the list of Intel maintainers.

> > Maybe add an internal exploder to get all the various
> > maintainers on a list if everyone really looks at all
> > patches to intel drivers.

> > INTEL ETHERNET DRIVERS
> > M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > M:	Intel Linux Support <linux.drivers@intel.com>
> > T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net.git
> > T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
> > S:	Supported
> > F:	drivers/net/ethernet/intel/

> I understand where your coming from and this has been been something
> that I have been trying to find a "reasonable" solution, which is harder
> to do than one would expect.
[]
> So how do we go about giving this spider web of complex coverage to some
> clear concise coverage in the MAINTAINERS?
[]
> If you have some ideas which may help resolve the issues, I am open to
> suggestions.

It's great that they all work on all intel drivers, but it seems
that you are the nominal maintainer and they are all developers
that might work on anything but nothing in particular.

I think an internal exploder email address would work well.
