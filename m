From: Greg KH <greg@kroah.com>
Subject: Re: wanPMC-CxT1E1
Date: Mon, 26 Oct 2009 13:41:44 -0700
Message-ID: <20091026204144.GA28436@kroah.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Bob Beers <bob.beers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:43361 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470AbZJZUp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 16:45:57 -0400
Content-Disposition: inline
In-Reply-To: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2009 at 04:22:08PM -0400, Bob Beers wrote:
> Hello List,
> 
> I am using subject named card[1] and it has a GPL driver that is
>  out-of-tree.  I have permission from the manufacturer to post and
>  discuss it, so I'd like to get started.  Where/how shall I post the code,
>  and my first patch which allows it to compile and run with the
>  kernel of RHEL/CentOS 5?  The tarball includes driver source and
>  a utility pmcc4cfg, and is 174 093 bytes.

Getting it to build on 2.6.31 is more important than RHEL5, we can't do
anything with an old kernel like that.

Do you have a pointer to where we can download the tarball?  I'll be
glad to add it to the staging tree so it can be cleaned up there before
being submitted to the main portion of the kernel tree.

thanks,

greg k-h
