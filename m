From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net/ipv4: Introduce IPSKB_FRAG_SEGS bit to
 inet_skb_parm.flags
Date: Tue, 19 Jul 2016 09:42:24 +0200
Message-ID: <c2f9c91d-71f8-d41e-834c-839faa8fc1d4@stressinduktion.org>
References: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
 <1468842574-1243-2-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: shmulik.ladkani@ravellosystems.com,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:35334 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752202AbcGSHm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 03:42:27 -0400
In-Reply-To: <1468842574-1243-2-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.07.2016 13:49, Shmulik Ladkani wrote:
> This flag indicates whether fragmentation of segments is allowed.
> 
> Formerly this policy was hardcoded according to IPSKB_FORWARDED (set by
> either ip_forward or ipmr_forward).
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Florian Westphal <fw@strlen.de>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
