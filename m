From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: Set vlan_feature on net_device
Date: Thu, 19 Jul 2012 10:50:04 -0700 (PDT)
Message-ID: <20120719.105004.1236683811159027712.davem@davemloft.net>
References: <1342639748-16276-1-git-send-email-brenohl@br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org
To: brenohl@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697Ab2GSRuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:50:05 -0400
In-Reply-To: <1342639748-16276-1-git-send-email-brenohl@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: brenohl@br.ibm.com
Date: Wed, 18 Jul 2012 14:29:08 -0500

> cxgb3 interface has a bad performance when VLAN is set. On my current
> setup, a PowerLinux 7R2, I am able to get around 7 Gbps on a TCP_STREAM
> (8 instances, 4k message).
> With this patch, I am able to reach 9.5 Gbps.
> 
> Signed-off-by: Breno Leitao <brenohl@br.ibm.com>

Applied.
