From: David Miller <davem@davemloft.net>
Subject: Re: pull request for net: batman-adv 2013-08-10
Date: Sat, 10 Aug 2013 15:39:22 -0700 (PDT)
Message-ID: <20130810.153922.1351681744983531065.davem@davemloft.net>
References: <1376168881-4079-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758904Ab3HJWjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 18:39:23 -0400
In-Reply-To: <1376168881-4079-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Sat, 10 Aug 2013 23:08:00 +0200

> here you have one fix intended for net/linux-3.11.
> 
> To avoid kernel paging errors, this patch takes care of re-assigning the value
> of skb->data to the related pointers after that the skb has been re-allocated.
> 
> Please pull or let me know of any problem!

Pulled, thanks.
