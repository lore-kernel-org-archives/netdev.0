From: Vipul Pandya <vipul@chelsio.com>
Subject: Re: [PATCH V2 0/4] Add IPv6 support for iWARP
Date: Tue, 02 Jul 2013 13:11:01 +0530
Message-ID: <51D2840D.9050902@chelsio.com>
References: <20130619.210805.224358826374432656.davem@davemloft.net> <51C3058D.205@chelsio.com>	<51D2779D.6060100@chelsio.com> <20130702.000714.1272040719463780891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SWise OGC <swise@opengridcomputing.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"roland@purestorage.com" <roland@purestorage.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"roland@kernel.org" <roland@kernel.org>,
	"sean.hefty@intel.com" <sean.hefty@intel.com>,
	"hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	"faisal.latif@intel.com" <faisal.latif@intel.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2629 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab3GBHlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 03:41:19 -0400
In-Reply-To: <20130702.000714.1272040719463780891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02-07-2013 12:37, David Miller wrote:
> From: Vipul Pandya <vipul@chelsio.com>
> Date: Tue, 02 Jul 2013 12:17:57 +0530
> 
>> I upgraded my GCC version from 4.4.6-4 to 4.8.1 and after that I am able
>> to see that warning. I will resubmit this series soon.
> 
> That's fine, but realize it is too late to submit this for the current
> merge window.
> 
I think that should be alright. We can target next kernel release
version for this series.
