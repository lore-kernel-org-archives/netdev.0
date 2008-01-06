From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.24 patch] fix netx-eth.c compilation
Date: Sat, 05 Jan 2008 23:55:31 -0800 (PST)
Message-ID: <20080105.235531.155666649.davem@davemloft.net>
References: <20080105214616.GE22232@does.not.exist>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: adrian.bunk@movial.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49976
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752686AbYAFHzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 02:55:39 -0500
In-Reply-To: <20080105214616.GE22232@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <adrian.bunk@movial.fi>
Date: Sat, 5 Jan 2008 23:46:16 +0200

> This was missed when commit e2ac455a18806b31c2d0da0a51d8740af5010b7a 
> fixed the compile errors in drivers/net/netx-eth.c caused by
> commit 09f75cd7bf13720738e6a196cc0107ce9a5bd5a0.
> 
> Signed-off-by: Adrian Bunk <adrian.bunk@movial.fi>

Applied, thanks Adrian.
