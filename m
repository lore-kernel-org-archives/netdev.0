From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Thu, 28 Jun 2007 15:16:42 +0200
Message-ID: <4683B4BA.3040605@trash.net>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net> <20070628075231.GB1618@ff.dom.local> <4683A897.4020809@trash.net> <20070628131850.GB3284@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	ranko@spidernet.net
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50369 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbXF1NRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 09:17:34 -0400
In-Reply-To: <20070628131850.GB3284@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Thu, Jun 28, 2007 at 02:24:55PM +0200, Patrick McHardy wrote:
> 
>>Jarek Poplawski wrote:
>>
>>>BTW #2, I hope it's about some new policy, but I cannot see
>>>any #ifdef CONFIG_NET_ESTIMATOR in this sch_htb patch.
>>
>>One of my previous patches for 2.6.23 killed that option,
>>the code was always compiled in anyways.
>>
> 
> 
> Maybe I look at something else but I cannot find this patch,
> at least here:
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.23.git;a=tree


No, its not in Dave's tree yet.

