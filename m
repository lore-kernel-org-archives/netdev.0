From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/05: netfilter fixes
Date: Mon, 09 Feb 2009 14:32:38 -0800 (PST)
Message-ID: <20090209.143238.25276576.davem@davemloft.net>
References: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42342
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751341AbZBIWcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 17:32:45 -0500
In-Reply-To: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon,  9 Feb 2009 17:39:27 +0100 (MET)

> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

I was going to pull from your tree and take it like that, but when I
pulled I got 5 real changes and 50 merges with net-2.6, yikes! :-)

If there was one or two merge changesets in there, I would have
taken it.  But anything more than that for a tree containing
5 bug fixes is excessive.

I'll apply these as patches, but I really do want to be able to
pull from your trees so please try to provide a cleaner tree
next time.

Thanks!
