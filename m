From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: use msecs_to_jiffies() rather than manual
 calculation
Date: Wed, 21 Dec 2011 15:46:32 -0500 (EST)
Message-ID: <20111221.154632.1500210370519475641.davem@davemloft.net>
References: <1324472236-9681-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: xi.wang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967Ab1LUUrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 15:47:42 -0500
In-Reply-To: <1324472236-9681-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xi Wang <xi.wang@gmail.com>
Date: Wed, 21 Dec 2011 07:57:16 -0500

> Also use mod_timer() instead of direct assignment to "expires".
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Applied, thanks.
