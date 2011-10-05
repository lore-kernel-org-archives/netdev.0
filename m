From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 0/8] skb fragment API: convert network drivers (part IV)
Date: Wed, 5 Oct 2011 12:17:17 -0700
Message-ID: <20111005191717.GC30378@suse.de>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39619 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934402Ab1JETZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 15:25:05 -0400
Content-Disposition: inline
In-Reply-To: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 05, 2011 at 11:28:30AM +0100, Ian Campbell wrote:
> The following series converts a forth batch of network drivers to the
> SKB pages fragment API introduced in 131ea6675c76.
> 
> There are two drivers/staging patches in here. I'm not sure who normally
> takes these, I'm sure you guys know though.

I take them.  As I don't have commit 131ea6675c76 in my tree
(staging-next), I'd have to wait until that patch gets merged into
Linus's tree, which should be after 3.2-rc1, right?  Mind if I hold off
in taking them until then?

thanks,

greg k-h
