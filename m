From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Tue, 24 Mar 2015 02:10:50 -0400 (EDT)
Message-ID: <20150324.021050.384709317309031128.davem@davemloft.net>
References: <1426807170-19258-1-git-send-email-johunt@akamai.com>
	<20150320.132029.103306583158863864.davem@davemloft.net>
	<550C5A98.5040305@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: johunt@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbbCXGKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 02:10:51 -0400
In-Reply-To: <550C5A98.5040305@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <johunt@akamai.com>
Date: Fri, 20 Mar 2015 12:36:24 -0500

> Would it be possible to queue up 355a901e6cf1 (tcp: make connect()
> mem charging friendly) for stable as well? That is the commit that
> fixes this problem in the tcp_connect()/tcp_send_syn_data() cases.

Done.
