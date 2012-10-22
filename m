From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [PATCH net-next] net:dev: remove double indentical
 assignment in dev_change_net_namespace().
Date: Sun, 21 Oct 2012 20:45:09 -0400 (EDT)
Message-ID: <20121021.204509.1408772133359245119.davem@davemloft.net>
References: <1350644970-2877-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, serge.hallyn@canonical.com
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932676Ab2JVApL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 20:45:11 -0400
In-Reply-To: <1350644970-2877-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Fri, 19 Oct 2012 13:09:30 +0200

> This patch removes double assignment of err to -EINVAL in dev_change_net_namespace().
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
