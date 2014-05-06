From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 06 May 2014 13:14:42 -0400 (EDT)
Message-ID: <20140506.131442.471106362264664281.davem@davemloft.net>
References: <20140505.232327.578134514220748085.davem@davemloft.net>
	<20140506155703.GA20391@cloud>
	<1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: josh@joshtriplett.org, andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	ak@linux.intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbaEFROo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:14:44 -0400
In-Reply-To: <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 May 2014 09:39:19 -0700

> I have started using linux on 386/486 pcs which had more than 2MB of
> memory, it makes me sad we want linux-3.16 to run on this kind of
> hardware, and consuming time to save few KB here and here.

+1
