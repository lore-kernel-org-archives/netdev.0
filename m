From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netns: fix proxy ARP entries listing on a netns
Date: Fri, 25 Nov 2011 13:24:57 -0500 (EST)
Message-ID: <20111125.132457.1189039148745073387.davem@davemloft.net>
References: <20111123.173613.1360696422325749253.davem@davemloft.net>
	<1322232089-31902-1-git-send-email-jorge@dti2.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604Ab1KYSZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 13:25:18 -0500
In-Reply-To: <1322232089-31902-1-git-send-email-jorge@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Date: Fri, 25 Nov 2011 15:41:29 +0100

> From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
> 
> Skip entries from foreign network namespaces.
> 
> V2:
>     Fixed as suggested by David Miller to avoid a goto.
> 
> Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>

Applied, thanks.
