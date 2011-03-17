From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: TX from KVM guest virtio_net to vhost issues
Date: Thu, 17 Mar 2011 08:00:58 +0200
Message-ID: <20110317060058.GI32049@redhat.com>
References: <1299707197.25664.173.camel@localhost.localdomain>
 <87d3ly2n81.fsf@rustcorp.com.au>
 <1300321214.3255.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33943 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab1CQGBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 02:01:40 -0400
Content-Disposition: inline
In-Reply-To: <1300321214.3255.40.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2011 at 05:20:14PM -0700, Shirley Ma wrote:
> This patch doesn't seem to help guest TX queue overrun.

Just making sure: what exactly was tested?
You did combine this with a vhost-net and qemu patches, right?

-- 
MST
