From: Greg KH <greg@kroah.com>
Subject: Re: wanPMC-CxT1E1
Date: Wed, 28 Oct 2009 18:05:35 -0700
Message-ID: <20091029010535.GA18723@kroah.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
 <20091026204144.GA28436@kroah.com>
 <4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Bob Beers <bob.beers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:57043 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756113AbZJ2BJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 21:09:11 -0400
Content-Disposition: inline
In-Reply-To: <4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2009 at 01:48:53PM -0400, Bob Beers wrote:
> On Mon, Oct 26, 2009 at 4:41 PM, Greg KH <greg@kroah.com> wrote:
> > Getting it to build on 2.6.31 is more important than RHEL5, we can't do
> > anything with an old kernel like that.
> 
> ok, so where do I start, I have a system ready to start
>  git cloning, and creating patches. I googled for a while
>  but didn't find a nice recipe for participating in the -staging
>  process.

Ick, this isn't going to be easy, a lot of work needs to be done on the
driver to get it just to build on the latest kernel tree.  I personally
don't have the time to do it right now, but will gladly accept patches
that add it to the staging tree if someone else wants to do it.

sorry,

greg k-h
