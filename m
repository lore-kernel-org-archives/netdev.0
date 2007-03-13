From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Removal of multipath cached (was Re: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check kmalloc() return value.)
Date: Tue, 13 Mar 2007 08:05:51 +0100
Message-ID: <20070313070551.GA1682@ff.dom.local>
References: <20070308.232908.92582631.davem@davemloft.net> <20070312115137.GA3270@ff.dom.local> <20070312.135311.71086996.davem@davemloft.net> <20070312222236.860fc180.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, amit2030@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:44742 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753150AbXCMHBj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 03:01:39 -0400
Content-Disposition: inline
In-Reply-To: <20070312222236.860fc180.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2007 at 10:22:36PM -0800, Andrew Morton wrote:
> > On Mon, 12 Mar 2007 13:53:11 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
...
> > And there is absolutely no negotiations about this, I've held back on
> > this for nearly 2 years, and nothing has happened, this code is not
> > maintained, nobody cares enough to fix the bugs, and even no
> > distributions enable it because it causes crashes.
> 
> Good stuff.
> 
> I suggest you put a big printk explaining the above into 2.6.21.
> 

Plus official way: Documentation/feature-remove-schedule.txt
in the next rc-git.

Jarek P.
