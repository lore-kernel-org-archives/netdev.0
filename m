From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_shifted_skb() adjustment of lost_cnt_hint
 for FACK
Date: Tue, 14 Feb 2012 14:41:29 -0500 (EST)
Message-ID: <20120214.144129.563139404903955823.davem@davemloft.net>
References: <1329200528-19718-1-git-send-email-ncardwell@google.com>
	<20120214.144033.848861752845052421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, ycheng@google.com, therbert@google.com,
	subramanian.vijay@gmail.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510Ab2BNTlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:41:40 -0500
In-Reply-To: <20120214.144033.848861752845052421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 14 Feb 2012 14:40:33 -0500 (EST)

> Applied, and queued up for -stable, thanks Neil.

Sorry for the typo, I truly meant to say "Neal" :-)
