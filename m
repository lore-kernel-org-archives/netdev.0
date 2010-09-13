From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next-2.6] flow: better memory management
Date: Mon, 13 Sep 2010 10:43:44 +0200
Message-ID: <20100913104344.308e9392@basil.nowhere.org>
References: <1284138025.24675.100.camel@edumazet-laptop>
	<87tyluk35t.fsf@basil.nowhere.org>
	<1284357111.5560.2533.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33598 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556Ab0IMInw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 04:43:52 -0400
In-Reply-To: <1284357111.5560.2533.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> At boot : Allocate tables for online cpus
> 
> When bringing up a cpu online : allocate table for this "new" cpu.

You're right, I misread the patch. I thought that part was missing.

> 
> What could be wrong with this ?

Nothing, that's fine.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
