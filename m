From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Remove unused OFFSET_IN_PAGE() macro
Date: Thu, 01 Mar 2012 17:22:19 -0500 (EST)
Message-ID: <20120301.172219.992238183401523944.davem@davemloft.net>
References: <1330584046-3938-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab2CAWWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 17:22:24 -0500
In-Reply-To: <1330584046-3938-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Wed, 29 Feb 2012 22:40:46 -0800

> From: Roland Dreier <roland@purestorage.com>
> 
> Signed-off-by: Roland Dreier <roland@purestorage.com>

Applied.

I assume you are aware of the same issue in the be2iscsi driver.
