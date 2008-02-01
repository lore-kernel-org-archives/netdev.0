From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM]: Fix statistics.
Date: Thu, 31 Jan 2008 17:15:16 -0800 (PST)
Message-ID: <20080131.171516.87797697.davem@davemloft.net>
References: <12017657921885-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753996AbYBABOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 20:14:55 -0500
In-Reply-To: <12017657921885-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Thu, 31 Jan 2008 16:49:52 +0900

> [PATCH][XFRM]: Fix statistics.
> 
> o Outbound sequence number overflow error status
>   is counted as XfrmOutStateSeqError.
> o Additionaly, it changes inbound sequence number replay
>   error name from XfrmInSeqOutOfWindow to XfrmInStateSeqError
>   to apply name scheme above.
> o Inbound IPv4 UDP encapsuling type mismatch error is wrongly
>   mapped to XfrmInStateInvalid then this patch fiex the error
>   to XfrmInStateMismatch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Applied, thank you.
