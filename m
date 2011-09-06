From: Andi Kleen <andi@firstfloor.org>
Subject: Re: ip_rt_bug route.c:1677 in 3.0
Date: Tue, 6 Sep 2011 22:55:50 +0200
Message-ID: <20110906205550.GM7761@one.firstfloor.org>
References: <20110906204545.GA29628@tassilo.jf.intel.com> <20110906.165135.572835380555941402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49362 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921Ab1IFUzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 16:55:51 -0400
Content-Disposition: inline
In-Reply-To: <20110906.165135.572835380555941402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2011 at 04:51:35PM -0400, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 6 Sep 2011 13:45:45 -0700
> 
> > My 3.0 workstation just spew:
> 
> "3.0.what?"

3.0.0 + some local changes unrelated to network.
> 
> > I wonder if a application could have caused this?
> 
> It's the routing cache hashing bug, fixed by:

Thanks.
-Andi
