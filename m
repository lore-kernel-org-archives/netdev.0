From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxge: make function table const
Date: Fri, 16 Sep 2011 19:20:52 -0400 (EDT)
Message-ID: <20110916.192052.1864507808627472676.davem@davemloft.net>
References: <20110916141001.2d4ca61d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850Ab1IPXU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 19:20:56 -0400
In-Reply-To: <20110916141001.2d4ca61d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 16 Sep 2011 14:10:01 -0700

> 
> All tables of function pointers should be const.
> The pre-existing code has lots of needless indirection...
> 
> Inspired by similar change in PAX.
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
