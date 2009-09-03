From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: net/core/dev.c cleanups
Date: Thu, 03 Sep 2009 05:17:44 -0700 (PDT)
Message-ID: <20090903.051744.231829560.davem@davemloft.net>
References: <4A9F7BFC.5000401@gmail.com>
	<20090903115026.GD2885@psychotron.lab.eng.brq.redhat.com>
	<4A9FB07D.5000509@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753648AbZICMR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 08:17:29 -0400
In-Reply-To: <4A9FB07D.5000509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Sep 2009 14:03:09 +0200

> [PATCH net-next-2.6] net: Remove debugging code
> 
> Remove a debugging aid I accidently left in previous 'cleanup' patch
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Sadly I went over the original patch with a fine-toothed comb
and I completely missed this :-(

Applied, thanks.
