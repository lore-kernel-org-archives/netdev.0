From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: cleanup the usage of *vlan in
 vlan_dev_hard_header
Date: Thu, 01 Aug 2013 13:12:30 -0700 (PDT)
Message-ID: <20130801.131230.25199405118866430.davem@davemloft.net>
References: <51F9FBCF.9060405@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shhuiw@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab3HAUMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 16:12:31 -0400
In-Reply-To: <51F9FBCF.9060405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Sheng-Hui <shhuiw@gmail.com>
Date: Thu, 01 Aug 2013 14:10:23 +0800

> We can use vlan directly after we get the pointer at the beginning
>     *vlan = vlan_dev_priv(dev)
> and do not use vlan_dev_priv(dev) to access its fields afterwards.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

This patch was corrupted by your email client.

Please read Documentation/email-clients.txt to learn how to
fix this, send a test patch to yourself, and only when you
can successfully apply the patch you receive in that test email
should you repost your patch again here.

Thanks.
