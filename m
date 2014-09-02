From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Configure device endianity on driver load
 and reset endianity on removal.
Date: Mon, 01 Sep 2014 22:56:18 -0700 (PDT)
Message-ID: <20140901.225618.2197547920541674134.davem@davemloft.net>
References: <31AFFC7280259C4184970ABA9AFE8B93E0800207@avmb3.qlogic.org>
	<20140901.145314.1237097170646182877.davem@davemloft.net>
	<B5657A6538887040AD3A81F1008BEC63B30338@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, netdev@vger.kernel.org,
	Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaIBF4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 01:56:31 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B30338@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 2 Sep 2014 05:47:49 +0000

> It's true #2 can solve the issue on its own for new kernels, but
> given the various existing distros out there (that don't include the
> fix) the effort of supporting those by adding #1 seems to be very
> small.

Ok, fair enough.
