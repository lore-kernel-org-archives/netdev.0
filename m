From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: [PATCH 3/3 (spin 2) resend] TCP_DEFER_ACCEPT updates - process
	as established
Date: Thu, 20 Mar 2008 19:55:46 -0400
Message-ID: <1206057346.13044.31.camel@tng>
References: <1206053493.13044.14.camel@tng> <1206053758.13044.24.camel@tng>
	 <20080320.161837.232769077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:43501 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937AbYCTXzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 19:55:39 -0400
In-Reply-To: <20080320.161837.232769077.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Thanks for the note - it can be hard to tell patch latency apart from
the drops.

You caught a mistake with the subject line - that patch was indeed spin
#3 - it was the exact same diff as I sent on March 6. 


-Patrick


On Thu, 2008-03-20 at 16:18 -0700, David Miller wrote:
> This looks wrong.  Are you sure you're resending the
> correct patch?
> 
> The most uptodate version was "spin 3" in which you
> incorporated coding style and checkpatch.pl fixes
> as recommended by Ilpo.

