From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Wed, 21 Nov 2012 18:12:34 -0500 (EST)
Message-ID: <20121121.181234.1434014622958965841.davem@davemloft.net>
References: <1353537131.26346.199.camel@shinybook.infradead.org>
	<20121121.174014.268181096393133050.davem@davemloft.net>
	<1353538374.26346.203.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, jgarzik@pobox.com, jasowang@redhat.com,
	netdev@vger.kernel.org, hayeswang@realtek.com, gilboad@gmail.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab2KVTKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 14:10:31 -0500
In-Reply-To: <1353538374.26346.203.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 21 Nov 2012 22:52:54 +0000

> On Wed, 2012-11-21 at 17:40 -0500, David Miller wrote:
>> On the contrary, for networking I submit everything manually and I
>> remove the CC: tags.
>> 
>> I have a queue on patchwork that I add such patches to, so that they
>> do not get lost.
> 
> Ah, right. Thanks for the correction. Is it even worth giving the hint
> that this should be for the stable tree (from v3.5 onwards), or should I
> leave you to work that all out for yourself? And if it *is* worth giving
> that hint, is it better to do it in a comment after --- at the end of
> the commit comment, rather than the "normal" 'Cc: stable' tag?

The more information you give in the commit message the better, that
way I don't have to guess :-)
