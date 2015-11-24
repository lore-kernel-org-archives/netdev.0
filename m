From: David Miller <davem@davemloft.net>
Subject: Re: MULTIPLE_TABLES and IP_ADVANCED_ROUTER
Date: Tue, 24 Nov 2015 13:10:25 -0500 (EST)
Message-ID: <20151124.131025.2229181704954661538.davem@davemloft.net>
References: <CAMuHMdXZpxnrU=FfFcf3sgX+Ym3RCVLA7dn_8mgUBpby18uDzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbbKXSK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:10:26 -0500
In-Reply-To: <CAMuHMdXZpxnrU=FfFcf3sgX+Ym3RCVLA7dn_8mgUBpby18uDzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sun, 22 Nov 2015 11:03:18 +0100

> Is there a reason why IP_MULTIPLE_TABLES and
> IP_MROUTE_MULTIPLE_TABLES depend on IP_ADVANCED_ROUTER, while their
> IPV6 counterparts don't?

It's just another thing that happened to diverge over time, there is
no real reason.
