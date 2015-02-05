From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Set RSS enablement based on hardware
 features
Date: Wed, 04 Feb 2015 20:32:18 -0800 (PST)
Message-ID: <20150204.203218.1739688392025415062.davem@davemloft.net>
References: <20150203201432.18889.73945.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbbBEEcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 23:32:19 -0500
In-Reply-To: <20150203201432.18889.73945.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 3 Feb 2015 14:14:32 -0600

> The RSS support requires enablement based on the features reported by
> the hardware. The setting of this flag is missing. Add support to
> set the RSS enablement flag based on the reported hardware features.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks Tom.
