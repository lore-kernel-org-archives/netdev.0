From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] net/ipv6/ndisc.c: remove unused variable
Date: Sat, 22 Mar 2008 18:04:30 -0700 (PDT)
Message-ID: <20080322.180430.22999528.davem@davemloft.net>
References: <Pine.LNX.4.64.0803151702580.24178@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48732
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754921AbYCWBEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 21:04:14 -0400
In-Reply-To: <Pine.LNX.4.64.0803151702580.24178@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Sat, 15 Mar 2008 17:03:20 +0100 (CET)

> The variable hlen is initialized but never used otherwise.
> 
> The semantic patch that makes this change is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks.
