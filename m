From: David Miller <davem@davemloft.net>
Subject: Re: Please queue commit e33d0ba8047b049 for stable
Date: Thu, 22 May 2014 17:14:36 -0400 (EDT)
Message-ID: <20140522.171436.2218567945524856233.davem@davemloft.net>
References: <CAHA+R7OK6aQho_cWC6wy1m9qQqz=i-vmwHmMEL8L6oYTXTkJpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaEVVOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 17:14:37 -0400
In-Reply-To: <CAHA+R7OK6aQho_cWC6wy1m9qQqz=i-vmwHmMEL8L6oYTXTkJpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Thu, 22 May 2014 14:09:07 -0700

> Please queue the following commit for stable:
> 
> commit e33d0ba8047b049c9262fdb1fcafb93cb52ceceb
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Thu Apr 3 09:28:10 2014 -0700
> 
>     net-gro: reset skb->truesize in napi_reuse_skb()
 ...
> unless Eric disagrees.
> 
> If I understand it correctly, it  fixes a real bug for all drivers calling
> napi_gro_frags(). But I am not sure which version of kernels it should
> apply to, it seems to be a long-standing bug.

Queued up, Eric what versions does it apply to?

Thanks.
