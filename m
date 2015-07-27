From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] lwtunnel: change prototype of
 lwtunnel_state_get()
Date: Mon, 27 Jul 2015 01:03:07 -0700 (PDT)
Message-ID: <20150727.010307.2033210673700214066.davem@davemloft.net>
References: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
	<1437733716-4494-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, roopa@cumulusnetworks.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbbG0IDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:03:07 -0400
In-Reply-To: <1437733716-4494-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 24 Jul 2015 12:28:36 +0200

> It saves some lines and simplify a bit the code when the state is returning
> by this function. It's also useful to handle a NULL entry.
> 
> To avoid too long lines, I've also renamed lwtunnel_state_get() and
> lwtunnel_state_put() to lwtstate_get() and lwtstate_put().
> 
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
