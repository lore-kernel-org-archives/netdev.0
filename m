From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Wed, 18 Jul 2007 13:40:12 -0700
Message-ID: <20070718134012.cde2f956.randy.dunlap@oracle.com>
References: <469E75AA.7040109@pimpmylinux.org>
	<Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gabriel C <crazy@pimpmylinux.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:45082 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbXGRUhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 16:37:31 -0400
In-Reply-To: <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007 16:23:09 -0400 (EDT) Robert P. J. Day wrote:

> On Wed, 18 Jul 2007, Gabriel C wrote:
> 
> > Everything 'depends on' EXPERIMENTAL should be marked as such,
> > visible in the menus.
> 
> rather than add all that extraneous dreck to the Kconfig files, i
> *really* wish folks would give serious thought to my earlier
> suggestion about a "maturity level" attribute that could be used to
> not only add a parenthesized maturity level during display, but could
> also be used to activate/deactivate entire levels in one operation.
> 
> there's no point adding all that redundant content when it can all be
> done automatically.

I like it.  Are there any kconfig patches to support this plan?


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
