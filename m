From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH] cxgb3: slay double assignment
Date: Sun, 24 Oct 2010 19:40:47 -0400
Message-ID: <20101024234047.GR8332@bombadil.infradead.org>
References: <20101022180003.GO8332@bombadil.infradead.org>
 <20101024.162611.02282476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kyle@mcmartin.ca, divy@chelsio.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34954 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab0JXXku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 19:40:50 -0400
Content-Disposition: inline
In-Reply-To: <20101024.162611.02282476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 24, 2010 at 04:26:11PM -0700, David Miller wrote:
> > Noticed this while building Fedora today... It's been
> > there since around 2007, so I guess a new gcc must be catching
> > these.
> > 
> > Signed-off-by: Kyle McMartin <kyle@redhat.com>
> 
> This patch doesn't apply.
> 

You already merged a patch to fix it, sorry for the noise.

--Kyle
