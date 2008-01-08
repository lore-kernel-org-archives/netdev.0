From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] Statistics: Add outbound-dropping error.
Date: Mon, 07 Jan 2008 21:46:37 -0800 (PST)
Message-ID: <20080107.214637.142434440.davem@davemloft.net>
References: <11997665683729-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753506AbYAHFqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:46:37 -0500
In-Reply-To: <11997665683729-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Tue,  8 Jan 2008 13:29:28 +0900

> [PATCH][XFRM] Statistics: Add outbound-dropping error.
> 
> o Increment PolError counter when flow_cache_lookup() returns
>   errored pointer.
> 
> o Increment NoStates counter at larval-drop.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Applied, thanks.
