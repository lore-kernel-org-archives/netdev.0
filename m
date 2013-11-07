From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] v3.12-rc5-139-gbdeeab6 assertion failed at
 drivers/net/bonding/bond_main.c (3398)
Date: Thu, 07 Nov 2013 15:12:12 -0500 (EST)
Message-ID: <20131107.151212.489598950578675166.davem@davemloft.net>
References: <20131019205222.GA18874@redhat.com>
	<20131019.184411.2017497732906948451.davem@davemloft.net>
	<20131107142418.GL19702@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas@glanzmann.de, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, nikolay@redhat.com, robbat2@gentoo.org
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002Ab3KGUMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 15:12:16 -0500
In-Reply-To: <20131107142418.GL19702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 7 Nov 2013 15:24:18 +0100

> Sorry for bringing this up - completely my fault. There are further
> reports
> of this bug in mainline. I've read the
> ./Documentation/networking/netdev-FAQ.txt but haven't seen a way to
> get a
> fix that got in net-next to the (correct) net tree.
> 
> Is there any way to do it?
> 
> Sorry again for the mess :-(.

Since we're in the merge window the tree going to Linus next would
be net-next, and the fix is there.

Once it hits Linus's tree I can queue it up for -stable.
