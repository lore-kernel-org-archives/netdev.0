From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Use wmb before updating current
 descriptor count
Date: Fri, 23 Oct 2015 07:02:19 -0700 (PDT)
Message-ID: <20151023.070219.511852623937724216.davem@davemloft.net>
References: <20151021203705.29412.11836.stgit@tlendack-t1.amdoffice.net>
	<20151023.025943.873672852211823864.davem@davemloft.net>
	<562A37B8.2090108@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christoffer.dall@linaro.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbbJWNpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:45:49 -0400
In-Reply-To: <562A37B8.2090108@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 23 Oct 2015 08:35:52 -0500

> Can you queue this up for stable?  It is applicable to 4.1 and 4.2.

Ok, done.
