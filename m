From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [net-next RFC PATCH 0/5] Series short description
Date: Wed, 07 Dec 2011 18:00:55 +1030
Message-ID: <87ty5cj0sw.fsf@rustcorp.com.au>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jason Wang <jasowang@redhat.com>, krkumar2@in.ibm.com,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47255 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754960Ab1LGKfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 05:35:42 -0500
In-Reply-To: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 05 Dec 2011 16:58:37 +0800, Jason Wang <jasowang@redhat.com> wrote:
> multiple queue virtio-net: flow steering through host/guest cooperation
> 
> Hello all:
> 
> This is a rough series adds the guest/host cooperation of flow
> steering support based on Krish Kumar's multiple queue virtio-net
> driver patch 3/3 (http://lwn.net/Articles/467283/).

Is there a real (physical) device which does this kind of thing?  How do
they do it?  Can we copy them?

Cheers,
Rusty.
