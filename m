From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] forcedeth: add transmit timestamping support
Date: Mon, 30 Apr 2012 21:47:06 -0400 (EDT)
Message-ID: <20120430.214706.2195282370105888390.davem@davemloft.net>
References: <1335553447-11964-1-git-send-email-willemb@google.com>
	<1335553447-11964-5-git-send-email-willemb@google.com>
	<1335599385.2900.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757648Ab2EABrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:47:11 -0400
In-Reply-To: <1335599385.2900.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 28 Apr 2012 09:49:45 +0200

> On Fri, 2012-04-27 at 15:04 -0400, Willem de Bruijn wrote:
>> Insert an skb_tx_timestamp call in both ndo_start_xmit routines
>> Tested to work for the nv_start_xmit_optimized case
>> 
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
