From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Use dev_queue_xmit for vport
 send.
Date: Thu, 22 Oct 2015 06:46:54 -0700 (PDT)
Message-ID: <20151022.064654.358792178806577005.davem@davemloft.net>
References: <1445407210-3898-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757588AbbJVNa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 09:30:27 -0400
In-Reply-To: <1445407210-3898-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 20 Oct 2015 23:00:10 -0700

> With use of lwtunnel, we can directly call dev_queue_xmit()
> rather than calling netdev vport send operation.
> Following change make tunnel vport code bit cleaner.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
