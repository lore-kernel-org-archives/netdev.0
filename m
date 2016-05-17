From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tipc: fix nametable publication field in nl compat
Date: Tue, 17 May 2016 12:34:33 -0400 (EDT)
Message-ID: <20160517.123433.103705936640622588.davem@davemloft.net>
References: <1463497057-1610-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbcEQQef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 12:34:35 -0400
In-Reply-To: <1463497057-1610-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Tue, 17 May 2016 16:57:37 +0200

> The publication field of the old netlink API should contain the
> publication key and not the publication reference.
> 
> Fixes: 44a8ae94fd55 (tipc: convert legacy nl name table dump to nl compat)
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>

Applied and queued up for -stable, thanks.
