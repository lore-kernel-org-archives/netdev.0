From: Greg KH <gregkh@suse.de>
Subject: Re: Netconsole crash on 2.6.38-rc3
Date: Thu, 17 Feb 2011 19:02:13 -0800
Message-ID: <20110218030213.GB17143@suse.de>
References: <20110218012847.GA8980@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:45119 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751630Ab1BRDFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 22:05:50 -0500
Content-Disposition: inline
In-Reply-To: <20110218012847.GA8980@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 17, 2011 at 05:28:47PM -0800, Sarah Sharp wrote:
> I'm trying to debug an xHCI driver crash on 2.6.38-rc3, and netconsole
> is crashing when I try to load it.  I will try to update to 2.6.38-rc5,
> but I'm sort of stuck on rc3 since Greg KH's USB tree is based on that.

No it isn't, it's synced up with 2.6.38-rc5 at the moment, which was
required to handle some merge conflicts.  You might want to update your
version :)

thanks,

greg k-h
