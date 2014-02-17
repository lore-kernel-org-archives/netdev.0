From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next resend] tcp: use zero-window when free_space is low
Date: Mon, 17 Feb 2014 14:34:31 -0500 (EST)
Message-ID: <20140217.143431.349062553619161172.davem@davemloft.net>
References: <1392292350-28800-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903AbaBQTed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:34:33 -0500
In-Reply-To: <1392292350-28800-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 13 Feb 2014 12:52:30 +0100

>  V1 of this patch was deferred, resending to get discussion going again.
>  Changes since v1:
>   - add reproducer to commit message
> 
>  Unfortunately I couldn't come up with something that has no magic
>  ('allowed >> 4') value.  I chose >>4 (1/16th) because it didn't cause
>  tput limitations in my 'full-mss-sized, steady state' netcat tests.
> 
>  Maybe someone has better idea?

I know this is going to be frustrating, but I've marked this 'deferred'
again.  Please resubmit after the testing and further discussions have
been worked out.

Thank you.
