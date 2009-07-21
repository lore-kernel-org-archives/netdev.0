From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/10] drivers/net: Move a dereference below a NULL test
Date: Tue, 21 Jul 2009 13:01:32 -0700 (PDT)
Message-ID: <20090721.130132.152098027.davem@davemloft.net>
References: <Pine.LNX.4.64.0907191726140.16542@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41229
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755681AbZGUUB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 16:01:27 -0400
In-Reply-To: <Pine.LNX.4.64.0907191726140.16542@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Sun, 19 Jul 2009 17:26:35 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> If the NULL test is necessary, then the dereference should be moved below
> the NULL test.
> 
> The semantic patch that makes this change is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
