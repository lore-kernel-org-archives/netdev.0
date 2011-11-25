From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ehea: Use round_jiffies_relative to align workqueue
Date: Fri, 25 Nov 2011 13:00:31 -0500 (EST)
Message-ID: <20111125.130031.2166791943647320639.davem@davemloft.net>
References: <20111123211302.2a37debb@kryten>
	<20111123211354.74a81a88@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab1KYSAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 13:00:35 -0500
In-Reply-To: <20111123211354.74a81a88@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Wed, 23 Nov 2011 21:13:54 +1100

> 
> Use round_jiffies_relative to align the ehea workqueue and avoid
> extra wakeups.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>

Applied.
