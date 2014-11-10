From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4 : Fix bug in DCB app deletion
Date: Mon, 10 Nov 2014 15:14:32 -0500 (EST)
Message-ID: <20141110.151432.986877712807790792.davem@davemloft.net>
References: <1415403681-4120-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbaKJUOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 15:14:34 -0500
In-Reply-To: <1415403681-4120-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Fri,  7 Nov 2014 15:41:21 -0800

> Unlike CEE, IEEE has a bespoke app delete call and does not rely on priority
> for app deletion
> 
> Fixes : 2376c879b80c ('cxgb4 : Improve handling of DCB negotiation or loss
>  thereof')
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.
