From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: use skb->len for accounting
Date: Fri, 23 Jul 2010 16:25:33 +0200
Message-ID: <4C49A65D.6090603@trash.net>
References: <1279856088-9004-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39147 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755568Ab0GWOZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 10:25:27 -0400
In-Reply-To: <1279856088-9004-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.07.2010 05:34, Changli Gao wrote:
> iptables: use skb->len for accounting
> 
> use skb->len for accounting as xt_quota does.
> 

Applied, thanks.
