From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] ipx: header length validation needed
Date: Wed, 9 Aug 2006 23:50:02 -0700
Message-ID: <20060810065002.GH3986@kroah.com>
References: <20060807134636.30f8b779@localhost.localdomain> <20060807.162433.26101101.davem@davemloft.net> <20060807163602.5c7a4a65@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:9188 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1161048AbWHJGuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 02:50:25 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060807163602.5c7a4a65@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 04:36:02PM -0700, Stephen Hemminger wrote:
> This patch will linearize and check there is enough data.
> It handles the pprop case as well as avoiding a whole audit of
> the routing code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

queued to -stable, thanks.

greg k-h

