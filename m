From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] dsa: Remove unnecessary exports
Date: Tue, 29 Nov 2011 01:20:18 -0500 (EST)
Message-ID: <20111129.012018.778222884731997632.davem@davemloft.net>
References: <1322449506.7454.34.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab1K2GU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:20:28 -0500
In-Reply-To: <1322449506.7454.34.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 28 Nov 2011 03:05:06 +0000

> I mistakenly exported functions from slave.c that are only called from
> dsa.c, part of the same module.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
