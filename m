From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [GIT PULL] Remove __dev* markings from the networking drivers
Date: Wed, 5 Dec 2012 18:48:33 -0800
Message-ID: <20121206024833.GA8469@kroah.com>
References: <20121203.153623.958379034481583512.davem@davemloft.net>
 <20121204.131726.103739824056368439.davem@davemloft.net>
 <20121204203052.GB32674@kroah.com>
 <20121204.160257.680931337109544105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wfp5p@virginia.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33291 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571Ab2LFCsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 21:48:37 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so4072636pad.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 18:48:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121204.160257.680931337109544105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2012 at 04:02:57PM -0500, David Miller wrote:
> From: Greg KH <gregkh@linuxfoundation.org>
> Date: Tue, 4 Dec 2012 12:30:52 -0800
> 
> > On Tue, Dec 04, 2012 at 01:17:26PM -0500, David Miller wrote:
> >> It seemse the function declarations were not properly reformatted
> >> after the __dev* tags were removed.  You can't just search and replace
> >> this kind of stuff.  The result looks terrible.
> >> 
> >> Greg please check for things like this next time you send me changes
> >> written by someone else.
> > 
> > Ick, sorry about that.  Want me to fix them all back up?  It's the least
> > I could do.
> 
> If you could do that, I'd really appreciate it.

I don't see these patches in your net-next branch yet, so should I just
make this against this branch and do a new pull request?  Or am I not
looking at net-next properly?

thanks,

greg k-h
