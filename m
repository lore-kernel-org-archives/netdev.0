From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 06 May 2014 13:17:52 -0400 (EDT)
Message-ID: <20140506.131752.740569380523989782.davem@davemloft.net>
References: <20140506155703.GA20391@cloud>
	<1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140506164546.GB20536@cloud>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: josh@joshtriplett.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaEFRRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:17:53 -0400
In-Reply-To: <20140506164546.GB20536@cloud>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: josh@joshtriplett.org
Date: Tue, 6 May 2014 09:45:46 -0700

> The kernel can do the same.  Consider the idea of analyzing a set of
> userspace programs, determining what kernel functionality they do and
> don't need, feeding that information into the kernel build process, and
> automatically dropping unused bits of the kernel.

Please make sure I'm not on the list of people who see reports for
bugs reported in that setup.

Thanks :-)
