From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: driver for Intel(R) 82598 PCI-Express 10GbE adapters
 (v4)
Date: Fri, 07 Sep 2007 18:36:50 -0400
Message-ID: <46E1D282.50902@garzik.org>
References: <20070906181733.19332.10926.stgit@localhost.localdomain>	<46E04793.6040901@intel.com> <20070906.124422.71092816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	ayyappan.veeraiyan@intel.com, akpm@linux-foundation.org,
	arjan@linux.intel.com, hch@infradead.org, billfink@mindspring.com,
	shemminger@linux-foundation.org, rick.jones2@hp.com,
	inaky@linux.intel.com, mb@bu3sch.de, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49043 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758651AbXIGWg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 18:36:58 -0400
In-Reply-To: <20070906.124422.71092816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Kok, Auke" <auke-jan.h.kok@intel.com>
> Date: Thu, 06 Sep 2007 11:31:47 -0700
> 
>> Also available through git:// and http:// here:
>>
>>    http://foo-projects.org/~sofar/ixgbe-20070905-submission.patch
>>    http://foo-projects.org/~sofar/ixgbe-20070905-submission.patch.bz2
>>    (git-am formatted!)
>>
>>    git://lost.foo-projects.org/~ahkok/linux-2.6 ixgbe-20070905-submission
> 
> To be honest I have absolutely no problems with this driver and we
> should just cut the crap and merge it in now.
> 
> Any objections anyone makes at this point is frankly nit picking crap
> which we can cure with followon cleanups and corrections.

Are you responding to a strawman or something?

AFAICS nobody objected to it, and Auke cleaned it up a la e1000e, which 
got queued during KS.

	Jeff



