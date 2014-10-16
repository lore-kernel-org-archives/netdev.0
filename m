From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4 : Improve handling of DCB negotiation
 or loss thereof
Date: Wed, 15 Oct 2014 23:24:52 -0400 (EDT)
Message-ID: <20141015.232452.1312886671821241352.davem@davemloft.net>
References: <1413425295-22824-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbaJPDYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 23:24:53 -0400
In-Reply-To: <1413425295-22824-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Wed, 15 Oct 2014 19:08:15 -0700

> Clear out any DCB apps we might have added to kernel table when we lose DCB
> sync (or IEEE equivalent event). IEEE allows individual components to work
> independently, so improve check for IEEE completion by specifying individual
> components.
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

net-next is not open at this time, please resubmit this patch
when it is open again.

Thank you.
