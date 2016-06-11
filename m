From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] tcp: add NV congestion control
Date: Fri, 10 Jun 2016 23:08:06 -0700 (PDT)
Message-ID: <20160610.230806.296438735347417432.davem@davemloft.net>
References: <1465445805-2521783-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com,
	stephen@networkplumber.org, kennetkl@ifi.uio.no
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbcFKGII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:08:08 -0400
In-Reply-To: <1465445805-2521783-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Wed, 8 Jun 2016 21:16:43 -0700

> Removed most of the module parameters
> 
> Tested in a rack using between 1 and 380 active TCP-NV flows.
> 
> Consists of the following patches:
> [PATCH net-next v2 1/2] tcp: add in_flight to tcp_skb_cb
> [PATCH net-next v2 2/2] tcp: add NV congestion control
> 
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

Series applied, thanks.
