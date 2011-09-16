From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pcnet32: constify function table
Date: Fri, 16 Sep 2011 19:20:33 -0400 (EDT)
Message-ID: <20110916.192033.1559515055214098900.davem@davemloft.net>
References: <20110916140626.2648c477@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850Ab1IPXUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 19:20:38 -0400
In-Reply-To: <20110916140626.2648c477@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 16 Sep 2011 14:06:26 -0700

> Function tables need to be const to prevent malicious use.
> 
> This is compile tested only.
> Gleaned from PAX.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
