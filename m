From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 0/4] virtio_net: Add MAC and VLAN filtering
Date: Fri, 30 Jan 2009 17:35:57 +1030
Message-ID: <200901301735.58236.rusty@rustcorp.com.au>
References: <20090129230502.2672.87669.stgit@debian.lart> <20090129.174913.91913239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, markmc@redhat.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39442 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbZA3HGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 02:06:06 -0500
In-Reply-To: <20090129.174913.91913239.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 January 2009 12:19:13 David Miller wrote:
> From: Alex Williamson <alex.williamson@hp.com>
> Date: Thu, 29 Jan 2009 16:05:02 -0700
> 
> > I'm not completely sure it's everything you're looking for Rusty,
> > but it does seem cleaner.  Let me know if this is closer to what
> > you're thinking.
> 
> Rusty, are these good?  If so, would you like you or I to take them?

Still nitpicking.  We'll wrestle a bit more, then I'll ack them to you.

These are 2.6.30 material, so no huge hurry AFAICT?

Thanks,
Rusty.
