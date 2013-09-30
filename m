From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qdisc: basic classifier - remove unnecessary
 initialization
Date: Mon, 30 Sep 2013 15:48:28 -0400 (EDT)
Message-ID: <20130930.154828.1093266834331156554.davem@davemloft.net>
References: <20130926174216.447555bd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36031 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756215Ab3I3Tsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:48:30 -0400
In-Reply-To: <20130926174216.447555bd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 26 Sep 2013 17:42:16 -0700

> err is set once, then first code resets it.
>   err = tcf_exts_validate(...)
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
