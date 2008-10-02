From: Greg KH <greg@kroah.com>
Subject: Re: atl2 network driver status
Date: Thu, 2 Oct 2008 16:21:48 -0700
Message-ID: <20081002232148.GA20003@kroah.com>
References: <20081002230246.GA11570@kroah.com> <20081002181731.6b8f563d@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiong.huang@atheros.com, csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:45038 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752516AbYJBXYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 19:24:51 -0400
Content-Disposition: inline
In-Reply-To: <20081002181731.6b8f563d@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 02, 2008 at 06:17:31PM -0500, Jay Cliburn wrote:
> On Thu, 2 Oct 2008 16:02:46 -0700
> Greg KH <greg@kroah.com> wrote:
> 
> > Hi,
> > 
> > In looking for drivers to add to drivers/staging/ I ran across the
> > atl2 driver that is currently in the Fedora and Ubuntu kernel trees.
> > 
> > This driver doesn't look to be scheduled for inclusion in the upstream
> > netdev git tree for submission for 2.6.28, is there any reason why it
> > is still out-of-the-tree?
> 
> Hi Greg,
> 
> It's in net-next-2.6.
> 
> http://marc.info/?l=linux-netdev&m=122144021209242&w=2

Nice, so that means it's going to be in 2.6.28?

thanks,

greg k-h
