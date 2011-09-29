From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cxgb4: Fix EEH on IBM P7IOC
Date: Thu, 29 Sep 2011 00:34:02 -0400 (EDT)
Message-ID: <20110929.003402.1451668842764449391.davem@davemloft.net>
References: <20110924161130.18521.39558.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dm@chelsio.com, swise@opengridcomputing.com, kxie@chelsio.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798Ab1I2EeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 00:34:06 -0400
In-Reply-To: <20110924161130.18521.39558.stgit@speedy5.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Sat, 24 Sep 2011 09:11:31 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Fix EEH recovery on new P Series platform by
> requesting fundamental reset.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
