From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [net-next PATCH] net: Document xfrm4_gc_thresh and
 xfrm6_gc_thresh
Date: Wed, 12 Aug 2015 12:27:45 +0200
Message-ID: <20150812102745.GD25499@secunet.com>
References: <20150811203501.1914.86746.stgit@ahduyck-vm-fedora22>
 <20150811.135152.34039482191606454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <alexander.h.duyck@redhat.com>, <netdev@vger.kernel.org>,
	<herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44048 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751046AbbHLK1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2015 06:27:48 -0400
Content-Disposition: inline
In-Reply-To: <20150811.135152.34039482191606454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 01:51:52PM -0700, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Tue, 11 Aug 2015 13:35:01 -0700
> 
> > This change adds documentation for xfrm4_gc_thresh and xfrm6_gc_thresh
> > based on the comments in commit eeb1b73378b56 ("xfrm: Increase the garbage
> > collector threshold").
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> 
> Thanks, I'll let Steffen review and pick this up.

Now applied to ipsec-next, thanks!
