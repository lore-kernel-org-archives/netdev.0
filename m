From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gso: Handle Trans-Ether-Bridging protocol in
 skb_network_protocol()
Date: Wed, 08 May 2013 13:15:47 -0700 (PDT)
Message-ID: <20130508.131547.1016073329398924443.davem@davemloft.net>
References: <1367995267-23443-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, amwang@redhat.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755472Ab3EHUPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 16:15:48 -0400
In-Reply-To: <1367995267-23443-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue,  7 May 2013 23:41:07 -0700

> Rather than having logic to calculate inner protocol in every
> tunnel gso handler move it to gso code. This simplifies code.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Cong Wang <amwang@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
