From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Update entry in af_family_clock_key_strings
Date: Wed, 23 Jul 2008 14:06:13 -0700 (PDT)
Message-ID: <20080723.140613.29502683.davem@davemloft.net>
References: <4887948A.6030304@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42209
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751534AbYGWVGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 17:06:13 -0400
In-Reply-To: <4887948A.6030304@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Wed, 23 Jul 2008 22:28:58 +0200

> In the merge phase of the CAN subsystem the 
> af_family_clock_key_strings[] have been added to sock.c in commit 
> 443aef0eddfa44c158d1b94ebb431a70638fcab4 
> (lockdep: fixup sk_callback_lock annotation). This trivial patch adds 
> the missing name for address family 29 (AF_CAN).
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied, thanks Oliver.
