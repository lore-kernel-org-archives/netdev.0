From: David Miller <davem@davemloft.net>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 10:14:00 -0400 (EDT)
Message-ID: <20120410.101400.1433881148267812355.davem@davemloft.net>
References: <CAHTX3dLRR09_QaA2BzmbCVAUVVGvr_P3s2d1KEgPLMYGGVzrpA@mail.gmail.com>
	<20120410.095245.1556231435417125908.davem@davemloft.net>
	<CAHTX3dLz9+A48u6ckGiDytBkyMrvgV0Zi3xfnt4RBmoagJbndA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	john.williams@petalogix.com
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338Ab2DJOOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 10:14:05 -0400
In-Reply-To: <CAHTX3dLz9+A48u6ckGiDytBkyMrvgV0Zi3xfnt4RBmoagJbndA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <monstr@monstr.eu>
Date: Tue, 10 Apr 2012 16:04:18 +0200

> I didn't report problem on any private held driver. I think you have
> misunderstand our later discussion about ll_temac driver where are
> some problems which at least

Thanks for the clarification.
