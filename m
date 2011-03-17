From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: TX from KVM guest virtio_net to vhost issues
Date: Thu, 17 Mar 2011 08:07:48 -0700
Message-ID: <1300374468.3255.41.camel@localhost.localdomain>
References: <1299707197.25664.173.camel@localhost.localdomain>
	 <87d3ly2n81.fsf@rustcorp.com.au>
	 <1300321214.3255.40.camel@localhost.localdomain>
	 <20110317060058.GI32049@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:48863 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab1CQPHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 11:07:55 -0400
In-Reply-To: <20110317060058.GI32049@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-17 at 08:00 +0200, Michael S. Tsirkin wrote:
> On Wed, Mar 16, 2011 at 05:20:14PM -0700, Shirley Ma wrote:
> > This patch doesn't seem to help guest TX queue overrun.
> 
> Just making sure: what exactly was tested?
> You did combine this with a vhost-net and qemu patches, right?
> 

I have virtio_net patch, I missed qemu patch. I will retest it.

Thanks
Shirley

