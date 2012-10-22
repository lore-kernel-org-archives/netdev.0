From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: Remove unnecessary #ifdef condition
Date: Sun, 21 Oct 2012 20:57:11 -0400 (EDT)
Message-ID: <20121021.205711.849828229402089244.davem@davemloft.net>
References: <1350648593-16370-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740Ab2JVA5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 20:57:12 -0400
In-Reply-To: <1350648593-16370-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Fri, 19 Oct 2012 17:39:53 +0530

> This patch also fixes the build failure caused due to removal of #ifdef
> CONFIG_CHELSIO_T4_OFFLOAD condition
> 
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

Applied to 'net'.

Please ALWAYS make it clear, in your Subject line, what tree you want
your patches applied to.
