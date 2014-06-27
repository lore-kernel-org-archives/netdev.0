From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 net] ipv6: Fix MLD Query message check
Date: Fri, 27 Jun 2014 09:05:27 +0200
Message-ID: <1403852727.7028.0.camel@localhost>
References: <1403834273-5147-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57833 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750928AbaF0HFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 03:05:31 -0400
In-Reply-To: <1403834273-5147-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-06-27 at 09:57 +0800, Hangbin Liu wrote:
> Based on RFC3810 6.2, we also need to check the hop limit and router alert
> option besides source address.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Yep, looks good

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
