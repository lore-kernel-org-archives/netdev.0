From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe-phy: PHY KX/KR mode differences
Date: Wed, 25 Feb 2015 16:57:55 -0500 (EST)
Message-ID: <20150225.165755.1190630794565192500.davem@davemloft.net>
References: <20150224164749.26012.40351.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932123AbbBYV54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 16:57:56 -0500
In-Reply-To: <20150224164749.26012.40351.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 24 Feb 2015 10:47:49 -0600

> The PHY requires different settings for the Decision Feedback Analyzer
> (DFE) when running in KX mode vs. KR mode. Update the code to change
> these settings when changing modes in order to provide a more stable
> link.
> 
> Additionally, adjust the 10GbE PQ skew default setting to a more sane
> value.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks Tom.
