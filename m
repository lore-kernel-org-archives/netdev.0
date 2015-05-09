From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] tipc: send explicit not supported error
 in nl compat
Date: Sat, 09 May 2015 16:40:26 -0400 (EDT)
Message-ID: <20150509.164026.1654492293159176489.davem@davemloft.net>
References: <1430913536-4206-1-git-send-email-richard.alpe@ericsson.com>
	<1430913536-4206-3-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbbEIUk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:40:28 -0400
In-Reply-To: <1430913536-4206-3-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Wed, 6 May 2015 13:58:56 +0200

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> The legacy netlink API treated EPERM (permission denied) as
> "operation not supported".
> 
> Reported-by: Tomi Ollila <tomi.ollila@iki.fi>
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Applied.
