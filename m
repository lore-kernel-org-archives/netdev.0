From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 10:55:37 -0500 (EST)
Message-ID: <20151124.105537.185897620062606312.davem@davemloft.net>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
	<20151123.145433.1554000376541433305.davem@davemloft.net>
	<20151124152744.GB20972@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, kernel-team@fb.com, davewatson@fb.com,
	alexei.starovoitov@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbKXPzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 10:55:39 -0500
In-Reply-To: <20151124152744.GB20972@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 24 Nov 2015 16:27:44 +0100

> Aside from Hannes comment -- KCM seems to be tied to the TLS work, i.e.
> I have the impression that KCM without ability to do TLS in the kernel
> is pretty much useless for whatever use case Tom has in mind.

I do not get this impression at all.

Tom's design document in the final patch looks legitimately what the
core use case is.
