From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Adjust for zero-based traffic class count
Date: Wed, 04 Feb 2015 20:28:42 -0800 (PST)
Message-ID: <20150204.202842.569864294109995352.davem@davemloft.net>
References: <20150203184955.14713.98160.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbbBEE2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 23:28:43 -0500
In-Reply-To: <20150203184955.14713.98160.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 3 Feb 2015 12:49:55 -0600

> The number of traffic classes reported by the hardware is zero-based
> so increment the value returned to get an actual count.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks Tom.
