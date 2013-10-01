From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/3] flow_dissector: factor out the ports
 extraction in skb_flow_get_ports
Date: Tue, 01 Oct 2013 17:47:45 -0400 (EDT)
Message-ID: <20131001.174745.269754568833232306.davem@davemloft.net>
References: <1380212024-3417-2-git-send-email-nikolay@redhat.com>
	<1380213202.3165.195.camel@edumazet-glaptop>
	<52446255.6040108@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, andy@greyhouse.net,
	fubar@us.ibm.com, vfalico@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423Ab3JAVrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 17:47:49 -0400
In-Reply-To: <52446255.6040108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 26 Sep 2013 18:35:33 +0200

> Dave would you apply Eric's fix in the net-next tree ?
> I'll then re-base on it.

I just merged net into net-next, please rebase.

Thanks.
