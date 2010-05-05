From: Pankaj Thakkar <pthakkar@vmware.com>
Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Tue, 4 May 2010 17:38:22 -0700
Message-ID: <20100505003822.GR8323@vmware.com>
References: <20100504230225.GP8323@vmware.com>
 <20100504170531.1e7122da@nehalam>
 <20100505001857.GQ8323@vmware.com>
 <20100504.173236.104064409.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:63277 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934633Ab0EEAiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 20:38:22 -0400
Content-Disposition: inline
In-Reply-To: <20100504.173236.104064409.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sure. We have been working on NPA for a while and have the code internally up
and running. Let me sync up internally on how and when we can provide the
vmxnet3 driver code so that people can look at it.


On Tue, May 04, 2010 at 05:32:36PM -0700, David Miller wrote:
> Date: Tue, 4 May 2010 17:32:36 -0700
> From: David Miller <davem@davemloft.net>
> To: Pankaj Thakkar <pthakkar@vmware.com>
> CC: "shemminger@vyatta.com" <shemminger@vyatta.com>,
> 	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
> 	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
> 	"virtualization@lists.linux-foundation.org"
>  <virtualization@lists.linux-foundation.org>,
> 	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
> 	Shreyas Bhatewara <sbhatewara@vmware.com>
> Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
> 
> From: Pankaj Thakkar <pthakkar@vmware.com>
> Date: Tue, 4 May 2010 17:18:57 -0700
> 
> > The purpose of this email is to introduce the architecture and the
> > design principles. The overall project involves more than just
> > changes to vmxnet3 driver and hence we though an overview email
> > would be better. Once people agree to the design in general we
> > intend to provide the code changes to the vmxnet3 driver.
> 
> Stephen's point is that code talks and bullshit walks.
> 
> Talk about high level designs rarely gets any traction, and often goes
> nowhere.  Give us an example implementation so there is something
> concrete for us to sink our teeth into.
