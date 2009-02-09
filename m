From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] drivers/atm: introduce missing kfree
Date: Sun, 08 Feb 2009 17:00:20 -0800 (PST)
Message-ID: <20090208.170020.93114261.davem@davemloft.net>
References: <Pine.LNX.4.64.0902082243200.25891@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55574
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752038AbZBIBA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 20:00:26 -0500
In-Reply-To: <Pine.LNX.4.64.0902082243200.25891@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Sun, 8 Feb 2009 22:44:16 +0100 (CET)

> Error handling code following a kmalloc should free the allocated data.
...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks Julia.
