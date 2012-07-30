From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: Add offload features to vlan interfaces
Date: Sun, 29 Jul 2012 23:18:48 -0700 (PDT)
Message-ID: <20120729.231848.1749249366881037474.davem@davemloft.net>
References: <1343415292-49323-1-git-send-email-brenohl@br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com,
	netdev@vger.kernel.org
To: brenohl@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab2G3GSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:18:49 -0400
In-Reply-To: <1343415292-49323-1-git-send-email-brenohl@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: brenohl@br.ibm.com
Date: Fri, 27 Jul 2012 13:54:52 -0500

> This patch fills the net_device vlan_features with the proper hardware features,
> thus, improving the vlan interface performance.
> 
> With the patch applied, I can see around 148% improvement on a TCP_STREAM test,
> from 3.5 Gb/s to 8.7 Gb/s. On TCP_RR, I see a 11% improvement, from 18k
> to 20. The CPU utilization is almost the same on both cases, from the comparison
> above.
> 
> Signed-off-by: Breno Leitao <brenohl@br.ibm.com>

Applied.
