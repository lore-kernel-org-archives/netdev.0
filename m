From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Thu, 28 Jun 2007 15:18:50 +0200
Message-ID: <20070628131850.GB3284@ff.dom.local>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net> <20070628075231.GB1618@ff.dom.local> <4683A897.4020809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:59548 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753178AbXF1NKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 09:10:37 -0400
Content-Disposition: inline
In-Reply-To: <4683A897.4020809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 28, 2007 at 02:24:55PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> >BTW #2, I hope it's about some new policy, but I cannot see
> >any #ifdef CONFIG_NET_ESTIMATOR in this sch_htb patch.
> 
> One of my previous patches for 2.6.23 killed that option,
> the code was always compiled in anyways.
> 

Maybe I look at something else but I cannot find this patch,
at least here:

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.23.git;a=tree

Jarek P.
