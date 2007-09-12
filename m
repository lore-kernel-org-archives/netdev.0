From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ixgbe: driver for Intel(R) 82598 PCI-Express 10GbE adapters
 (v4)
Date: Wed, 12 Sep 2007 11:47:38 -0700
Message-ID: <46E8344A.4020404@intel.com>
References: <20070906181733.19332.10926.stgit@localhost.localdomain>	<46E04793.6040901@intel.com> <20070906.124422.71092816.davem@davemloft.net> <46E1D282.50902@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, ayyappan.veeraiyan@intel.com,
	akpm@linux-foundation.org, arjan@linux.intel.com,
	hch@infradead.org, billfink@mindspring.com,
	shemminger@linux-foundation.org, rick.jones2@hp.com,
	inaky@linux.intel.com, mb@bu3sch.de, nhorman@tuxdriver.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17927 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967515AbXILSrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 14:47:43 -0400
In-Reply-To: <46E1D282.50902@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> David Miller wrote:
>> From: "Kok, Auke" <auke-jan.h.kok@intel.com>
>> Date: Thu, 06 Sep 2007 11:31:47 -0700
>>
>>> Also available through git:// and http:// here:
>>>
>>>    http://foo-projects.org/~sofar/ixgbe-20070905-submission.patch
>>>    http://foo-projects.org/~sofar/ixgbe-20070905-submission.patch.bz2
>>>    (git-am formatted!)
>>>
>>>    git://lost.foo-projects.org/~ahkok/linux-2.6 ixgbe-20070905-submission
 >>
>> To be honest I have absolutely no problems with this driver and we
>> should just cut the crap and merge it in now.
> 
> AFAICS nobody objected to it, and Auke cleaned it up a la e1000e, which 
> got queued during KS.

Jeff,

as of today ixgbe is ready for a possible merge with davem's net-2.6.24 - I sent 
you the patch earlier today as well as to David and Andrew.

Since this takes away the only obstruction that I can see that would prevent a 
normal merge, I would like to know if you are thinking of merging this driver 
for 2.6.24 or not. No pressure of course, but the approaching merge window is 
dooming and postponing this driver for a whole kernel version just because you 
accidentally missed or forgot it would be a shame.

Auke
