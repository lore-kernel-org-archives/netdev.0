From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] kaweth:BQL support
Date: Mon, 12 Nov 2012 08:38:57 +0100
Message-ID: <5350156.Kb3Hv9rKLR@linux-lqwf.site>
References: <1352463587-23899-1-git-send-email-oliver@neukum.org> <1352466944.19779.556.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:58330 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab2KLHiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 02:38:55 -0500
In-Reply-To: <1352466944.19779.556.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 November 2012 05:15:44 Eric Dumazet wrote:
> I am curious to know if it changes anything on the behavior of this
> network adapter ?
> 
> Because it seems queue is stopped anyway when a packet is in transmit.

True, I'd need to also do more changes on the tx path.

Dave, for now please disregard the patch.

	Regards
		Oliver
