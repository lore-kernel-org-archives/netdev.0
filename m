From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] ipv4: Fix ip-header identification for gso
 packets.
Date: Mon, 25 Mar 2013 12:29:18 -0400 (EDT)
Message-ID: <20130325.122918.1454194776490435084.davem@davemloft.net>
References: <1364182567-1667-1-git-send-email-pshelar@nicira.com>
	<1364183295.2532.9.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758617Ab3CYQ3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:29:20 -0400
In-Reply-To: <1364183295.2532.9.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 25 Mar 2013 11:48:15 +0800

> On Sun, 2013-03-24 at 20:36 -0700, Pravin B Shelar wrote:
>> Following patch fixes ip-header identification according to comments from
>> David Miller and Cong Wang.
>> First two patches reverts fixes to upper layer gso handlers which is not
>> required after fixing ipv4 gso handler.
>> 
> 
> Looks good to me now:
> 
> Acked-by: Cong Wang <amwang@redhat.com>

Looks good to me too, all applied, thanks.
