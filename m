From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ixgbe: driver for Intel(R) 82598 PCI-Express 10GbE
 adapters (v4)
Date: Thu, 6 Sep 2007 15:39:50 -0700
Message-ID: <20070906153950.466a5c77.akpm@linux-foundation.org>
References: <20070906181733.19332.10926.stgit@localhost.localdomain>
	<46E04793.6040901@intel.com>
	<20070906.124422.71092816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org, jeff@garzik.org,
	ayyappan.veeraiyan@intel.com, arjan@linux.intel.com,
	hch@infradead.org, billfink@mindspring.com,
	shemminger@linux-foundation.org, rick.jones2@hp.com,
	inaky@linux.intel.com, mb@bu3sch.de, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33544 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757641AbXIFWoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 18:44:00 -0400
In-Reply-To: <20070906.124422.71092816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thu, 06 Sep 2007 12:44:22 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> From: "Kok, Auke" <auke-jan.h.kok@intel.com>
> Date: Thu, 06 Sep 2007 11:31:47 -0700
> 
> > Also available through git:// and http:// here:
> > 
> >    http://foo-projects.org/~sofar/ixgbe-20070905-submission.patch
> >    http://foo-projects.org/~sofar/ixgbe-20070905-submission.patch.bz2
> >    (git-am formatted!)
> > 
> >    git://lost.foo-projects.org/~ahkok/linux-2.6 ixgbe-20070905-submission
> 
> To be honest I have absolutely no problems with this driver and we
> should just cut the crap and merge it in now.
> 
> Any objections anyone makes at this point is frankly nit picking crap
> which we can cure with followon cleanups and corrections.

fyi, I've been dropping this tree because changes in the net-2.6 tree kind
of wreck it.

We can merge it into Jeff's tree OK but I'll probably disable it in Kconfig
and whoever merges second will have some fixing to do..
