From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] VXLAN: fix potential NULL dereference in
 arp_reduce()
Date: Tue, 18 Mar 2014 16:10:09 -0400 (EDT)
Message-ID: <20140318.161009.1598213938948294397.davem@davemloft.net>
References: <201403181632.s2IGWTjT003613@lab1.dls>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932348AbaCRUKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 16:10:11 -0400
In-Reply-To: <201403181632.s2IGWTjT003613@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <dlstevens@us.ibm.com>
Date: Tue, 18 Mar 2014 12:32:29 -0400

> 	This patch fixes a NULL pointer dereference in the event of an
> skb allocation failure in arp_reduce().
> 
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

Applied, thanks.

Please refer to subsystems in your Subject lines using lowercase
letters, as is the convention these days.  I've fixed it up this
time.

Thanks.
