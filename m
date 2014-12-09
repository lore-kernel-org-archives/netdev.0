From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: the next chunk of iov_iter-net stuff for review
Date: Tue, 9 Dec 2014 22:49:28 +0000
Message-ID: <20141209224928.GL22149@ZenIV.linux.org.uk>
References: <20141209210414.GJ22149@ZenIV.linux.org.uk>
 <20141209.161712.1258837733606317716.davem@davemloft.net>
 <20141209212337.GK22149@ZenIV.linux.org.uk>
 <20141209.163758.1934464464299516168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37443 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831AbaLIWta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 17:49:30 -0500
Content-Disposition: inline
In-Reply-To: <20141209.163758.1934464464299516168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2014 at 04:37:58PM -0500, David Miller wrote:
> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Tue, 9 Dec 2014 21:23:37 +0000
> 
> > On Tue, Dec 09, 2014 at 04:17:12PM -0500, David Miller wrote:
> >> From: Al Viro <viro@ZenIV.linux.org.uk>
> >> Date: Tue, 9 Dec 2014 21:04:14 +0000
> >> 
> >> > Well, I've got no comments whatsoever on the networking side of things;
> >> 
> >> I've been away for more than 10 days, so I personally haven't had time
> >> to review any of it.
> >> 
> >> Why don't you respin and I'll try to allocate some review time myself?
> > 
> > Umm...  Do you want a rebase on top of current net-next/master?
> 
> Sure, why not?

OK, rebase is in
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-davem-2,
individual patches - in followups (first 13 - iov_iter, then 12 net-related)
