From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bfin_mac: fix memleak in mii_bus{probe|remove}
Date: Tue, 18 May 2010 14:15:17 -0700 (PDT)
Message-ID: <20100518.141517.215575310.davem@davemloft.net>
References: <AANLkTikcB3f0KmkcnDsV46Xrpm3WcCLQklxbLSJfMTlW@mail.gmail.com>
	<20100518113445.GA28386@coldcone>
	<20100518.141318.45114681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sonic.adi@gmail.com, michael.hennerich@analog.com,
	cooloney@kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	netdev@vger.kernel.org
To: kirjanov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53930
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754062Ab0ERVPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 17:15:07 -0400
In-Reply-To: <20100518.141318.45114681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 18 May 2010 14:13:18 -0700 (PDT)

> From: Denis Kirjanov <kirjanov@gmail.com>
> Date: Tue, 18 May 2010 15:34:46 +0400
> 
>> [PATCH] bfin_mac: fix memleak in mii_bus_{probe|remove}
>> Fix memory leak with miibus->irq
>> 
>> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> 
> I've already applied the original patch.

Sorry, ignore this, I didn't see that this is a new patch.
