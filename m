From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] doc:networking: Fix default value
 (icmp_ignore_bogus_error_responses).
Date: Fri, 07 Jun 2013 23:32:08 -0700 (PDT)
Message-ID: <20130607.233208.718640098549055737.davem@davemloft.net>
References: <1370672179-2664-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967Ab3FHGcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 02:32:11 -0400
In-Reply-To: <1370672179-2664-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Sat,  8 Jun 2013 09:16:19 +0300

> This patch fixes icmp_ignore_bogus_error_responses default value to be 1 instead 
> of FALSE. It is initialized to 1 in icmp_sk_init().
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks Rami.
