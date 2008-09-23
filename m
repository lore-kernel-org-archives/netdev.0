From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/8] net/atm/lec.c: drop code after return
Date: Mon, 22 Sep 2008 19:24:53 -0700 (PDT)
Message-ID: <20080922.192453.20197764.davem@davemloft.net>
References: <200809222150.m8MLofR7031869@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, julia@diku.dk, chas@cmf.nrl.navy.mil,
	richard.genoud@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60083
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754226AbYIWCZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:25:05 -0400
In-Reply-To: <200809222150.m8MLofR7031869@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:50:41 -0700

> From: Julia Lawall <julia@diku.dk>
> 
> The break after the return serves no purpose.
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Reviewed-by: Richard Genoud <richard.genoud@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6
