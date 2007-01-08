From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] netfilter: ipt_MASQUERADE: NULL check in device_cmp [BUG] panic 2.6.20-rc3 in nf_conntrack
Date: Mon, 8 Jan 2007 09:13:15 +0100
Message-ID: <20070108081314.GB1665@ff.dom.local>
References: <20070101214000.4573f575.akpm@osdl.org> <20070104135155.GA4682@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?us-ascii?B?PT9JU08tODg1OS0yP1E/TWFsdGVfU2Nocj1GNmRlcj89?=
	<MalteSch@gmx.de>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:56980 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932588AbXAHIL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 03:11:26 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20070104135155.GA4682@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 04, 2007 at 02:51:55PM +0100, Jarek Poplawski wrote:
> 
> Hello,
> 
> Below I attach a patch proposal.

It seems I wasted some time...

I wonder if there is any reason to forward netfilter
bugs to netdev if patches from netfilter aren't cc-d
here? It seems netfilter is really independent from
net.

Before sending the patch I did some seeking by subject
on both lists and found nothing. Now I see it was in
netfilter-devel, but wasn't even titled as patch
and no "masquerade" in title also. Maybe I should
check netfilter svn also but can't find it yet... 

Of course I'll try to remember to ignore such messages
next time, but others may be tricked.

Regards,
Jarek P.

PS: After some confusion I've also found a good side:
other systems will wet themselves when they see
linux has such work resources it can fix bugs twice. 
