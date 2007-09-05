From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 9/11] cxgb3 - engine microcode update
Date: Wed, 5 Sep 2007 10:30:29 -0400
Message-ID: <20070905143029.GC19543@havoc.gtf.org>
References: <20070822034947.9404.87301.stgit@speedy5> <46D819CE.5050207@garzik.org> <46DEB664.2090704@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51855 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755731AbXIEOaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 10:30:30 -0400
Content-Disposition: inline
In-Reply-To: <46DEB664.2090704@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 05, 2007 at 09:00:04AM -0500, Steve Wise wrote:
> 
> 
> Jeff Garzik wrote:
> >Divy Le Ray wrote:
> >>From: Divy Le Ray <divy@chelsio.com>
> >>
> >>Load microcode engine when the interface
> >>is configured up.
> >>Bump up version to 1.1.0.
> >>Allow the driver to be and running with
> >>older microcode images.
> >>Allow ethtool to log the microcode version.
> >>
> >>Signed-off-by: Divy Le Ray <divy@chelsio.com>
> >
> >ACK patches 9-14, but dropped, since they do not apply to #upstream 
> >(probably due to fixes sent into 2.6.23-rc)
> >
> 
> Hey Jeff,
> 
> I think 9-14 still need to be incorporated.  I don't see them in your 
> upstream branch, and they aren't in linus' tree either.

I am not the blocker here.  Re-read the email you quoted.

	Jeff, still waiting for the patches



