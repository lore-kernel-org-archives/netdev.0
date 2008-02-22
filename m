From: Anders Eriksson <aeriksson@fastmail.fm>
Subject: Re: lockdep warning
Date: Fri, 22 Feb 2008 17:32:13 +0100
Message-ID: <20080222163213.5BDE293C12F@tippex.mynet.homeunix.org>
References: <20080222104049.BD95A93C12F@tippex.mynet.homeunix.org> <Pine.LNX.4.64.0802221214020.7699@twin.jikos.cz> <20080222131608.7FC1E93C12F@tippex.mynet.homeunix.org> <Pine.LNX.4.64.0802221420250.30955@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anders Eriksson <aeriksson@fastmail.fm>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch-smtp01.sth.basefarm.net ([80.76.149.212]:59355 "EHLO
	ch-smtp01.sth.basefarm.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757077AbYBVQcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 11:32:21 -0500
In-reply-to: <Pine.LNX.4.64.0802221420250.30955@jikos.suse.cz> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


jkosina@suse.cz said:
> > Any chance that
> > 	git revert 69cc64d8d92
> > makes this report go away?  

I've tested the patch and I no longer get that lock thing in my syslog.

/A

