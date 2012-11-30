From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: respin of __dev* removal patches
Date: Fri, 30 Nov 2012 15:39:47 -0800
Message-ID: <20121130233947.GA17353@kroah.com>
References: <20121130221555.2AA738019A@viridian.itc.virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Bill Pemberton <wfp5p@viridian.itc.virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:61274 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215Ab2K3Xjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 18:39:51 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so678771pad.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 15:39:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121130221555.2AA738019A@viridian.itc.virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2012 at 05:15:54PM -0500, Bill Pemberton wrote:
> I've got a respin of the hotplug removal patches for the networking
> subsystem.  I don't want to irritate you like the big patch set did,
> so before I submit them, what do you want to see that will keep your
> pain to a minimum?
> 
> I've redone them so that all the __dev* removals are done at once so
> there won't be one patch for __devinit, one for __devexit, etc.  I've
> also broken them down into chunks following what's in the MAINTAINERS
> file.  The result is 103 patches.

As that's a lot of patches to handle through patchwork, would it be
easier for the network maintainers for me to just put these in a tree
they can pull from?  I will base it off of net-next.

thanks,

greg k-h
