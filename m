From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/6] s390: network driver features and fixes for
 net-next
Date: Wed, 08 Feb 2012 20:28:47 -0500 (EST)
Message-ID: <20120208.202847.2263101124035209366.davem@davemloft.net>
References: <20120208101944.272235343@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab2BIB2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 20:28:53 -0500
In-Reply-To: <20120208101944.272235343@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Wed, 08 Feb 2012 11:19:44 +0100

> here are some s390 network driver features and fixes for net-next
> 
> shortlog:
> 
> Ursula Braun (5)
> af_iucv: remove IUCV-pathes completely
> af_iucv: block writing if msg limit is exceeded
> af_iucv: change net_device handling for HS transport
> af_iucv: allow retrieval of maximum message size
> qeth: add wake_up on write channel
> 
> Frank Blaschka (1)
> qeth: add query OSA address table support

All applied.
