From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] udp: increase inner ip header ID during
 segmentation
Date: Fri, 22 Mar 2013 10:24:11 -0400 (EDT)
Message-ID: <20130322.102411.2193243457687880725.davem@davemloft.net>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
	<1363948292-9902-1-git-send-email-amwang@redhat.com>
	<1363948292-9902-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, edumazet@google.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116Ab3CVOYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:24:13 -0400
In-Reply-To: <1363948292-9902-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 22 Mar 2013 18:31:32 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Similar to GRE tunnel, UDP tunnel should take care of IP header ID
> too.
> 
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
