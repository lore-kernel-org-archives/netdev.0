From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ipv4: factorize cache clearing for batched
 unregister operations
Date: Mon, 16 Nov 2009 16:06:46 -0800
Message-ID: <20091116160646.39c0a1ac@nehalam>
References: <200911170149.50011.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51633 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754532AbZKQAHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 19:07:00 -0500
In-Reply-To: <200911170149.50011.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 01:49:49 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  net/ipv4/fib_frontend.c |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)

And what about IPV6?


-- 
