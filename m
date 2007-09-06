From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: driver for Intel(R) 82598 PCI-Express 10GbE
 adapters (v4)
Date: Thu, 06 Sep 2007 12:44:22 -0700 (PDT)
Message-ID: <20070906.124422.71092816.davem@davemloft.net>
References: <20070906181733.19332.10926.stgit@localhost.localdomain>
	<46E04793.6040901@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	ayyappan.veeraiyan@intel.com, akpm@linux-foundation.org,
	arjan@linux.intel.com, hch@infradead.org, billfink@mindspring.com,
	shemminger@linux-foundation.org, rick.jones2@hp.com,
	inaky@linux.intel.com, mb@bu3sch.de, nhorman@tuxdriver.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:58098
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751532AbXIFTp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 15:45:28 -0400
In-Reply-To: <46E04793.6040901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Thu, 06 Sep 2007 11:31:47 -0700

> Also available through git:// and http:// here:
> 
>    http://foo-projects.org/~sofar/ixgbe-20070905-submission.patch
>    http://foo-projects.org/~sofar/ixgbe-20070905-submission.patch.bz2
>    (git-am formatted!)
> 
>    git://lost.foo-projects.org/~ahkok/linux-2.6 ixgbe-20070905-submission

To be honest I have absolutely no problems with this driver and we
should just cut the crap and merge it in now.

Any objections anyone makes at this point is frankly nit picking crap
which we can cure with followon cleanups and corrections.
