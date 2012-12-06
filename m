From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [GIT PULL] Remove __dev* markings from the networking drivers
Date: Wed, 5 Dec 2012 18:56:44 -0800
Message-ID: <20121206025644.GA27279@kroah.com>
References: <20121204.160257.680931337109544105.davem@davemloft.net>
 <20121206024833.GA8469@kroah.com>
 <20121205.215121.1118396738034568895.davem@davemloft.net>
 <20121205.215246.789211879539058594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wfp5p@virginia.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61323 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156Ab2LFC4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 21:56:49 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so4139128pbc.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 18:56:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121205.215246.789211879539058594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2012 at 09:52:46PM -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 05 Dec 2012 21:51:21 -0500 (EST)
> 
> > From: Greg KH <gregkh@linuxfoundation.org>
> > Date: Wed, 5 Dec 2012 18:48:33 -0800
> > 
> >> On Tue, Dec 04, 2012 at 04:02:57PM -0500, David Miller wrote:
> >>> From: Greg KH <gregkh@linuxfoundation.org>
> >>> Date: Tue, 4 Dec 2012 12:30:52 -0800
> >>> 
> >>> > On Tue, Dec 04, 2012 at 01:17:26PM -0500, David Miller wrote:
> >>> >> It seemse the function declarations were not properly reformatted
> >>> >> after the __dev* tags were removed.  You can't just search and replace
> >>> >> this kind of stuff.  The result looks terrible.
> >>> >> 
> >>> >> Greg please check for things like this next time you send me changes
> >>> >> written by someone else.
> >>> > 
> >>> > Ick, sorry about that.  Want me to fix them all back up?  It's the least
> >>> > I could do.
> >>> 
> >>> If you could do that, I'd really appreciate it.
> >> 
> >> I don't see these patches in your net-next branch yet, so should I just
> >> make this against this branch and do a new pull request?  Or am I not
> >> looking at net-next properly?
> > 
> > The drivers/net changes definitely are in my net-next tree.  I only use
> > the 'master' branch.
> 
> The merge commit is 682d7978aee072f411fc747d32954a8371dd7b1b

Ugh, sorry about that, I forgot I had pointed my repo at my copy, not
yours, my fault, you are right.  sorry for the noise.

greg "time to knock off for the night, I'm doing stupid mistakes" k-h
