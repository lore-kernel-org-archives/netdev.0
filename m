From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: remove prune parameter for fib6_clean_all
Date: Fri, 27 Dec 2013 16:14:31 +0100
Message-ID: <20131227151431.GS14073@order.stressinduktion.org>
References: <1388133158-4142-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54058 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604Ab3L0POd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 10:14:33 -0500
Content-Disposition: inline
In-Reply-To: <1388133158-4142-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 27, 2013 at 04:32:38PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> since the prune parameter for fib6_clean_all always is 0, remove it.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Nice cleanup, thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
