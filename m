From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] arp: Do not perturb drop profiles with
 ignored ARP packets
Date: Sun, 28 Sep 2014 17:31:07 -0400 (EDT)
Message-ID: <20140928.173107.901676705768120733.davem@davemloft.net>
References: <20140925175528.8DFF329004BA@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbaI1VbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 17:31:09 -0400
In-Reply-To: <20140925175528.8DFF329004BA@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Thu, 25 Sep 2014 10:55:28 -0700 (PDT)

> 
> From: Rick Jones <rick.jones2@hp.com>
> 
> We do not wish to disturb dropwatch or perf drop profiles with an ARP
> we will ignore.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

This is fine, applied, thanks Rick.
