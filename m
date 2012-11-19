From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 200/493] irda: remove use of __devinit
Date: Mon, 19 Nov 2012 11:30:02 -0800
Message-ID: <20121119193002.GB16976@kroah.com>
References: <1353349642-3677-200-git-send-email-wfp5p@virginia.edu>
 <20121119.140654.780679585475336928.davem@davemloft.net>
 <20121119192121.GA16694@kroah.com>
 <20121119.142446.1954365383179623684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wfp5p@virginia.edu, samuel@sortiz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33723 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438Ab2KSTaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:30:05 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so667315pad.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 11:30:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121119.142446.1954365383179623684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 19, 2012 at 02:24:46PM -0500, David Miller wrote:
> From: Greg KH <gregkh@linuxfoundation.org>
> Date: Mon, 19 Nov 2012 11:21:21 -0800
> 
> > On Mon, Nov 19, 2012 at 02:06:54PM -0500, David Miller wrote:
> >> 
> >> It is absolutely not reasonable to post nearly 500 patches all
> >> at the same time.
> >> 
> >> Do not do this ever again.
> > 
> > Bill did this with the assumption that I would take them through my
> > driver-core tree, as I asked that he do this work.  The 000 message said
> > that, but that wasn't sent out to all of the recipients, so I can
> > understand how you didn't see this.
> > 
> > Also, I was the only one that got all 500 emails, everyone else should
> > have only seen a small quantity.
> 
> I had to purge nearly 100 out of networking's patchwork.
> 
> This is unacceptable.

Ok, fair enough, sorry about that.

greg k-h
