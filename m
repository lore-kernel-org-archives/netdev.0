From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] at86rf230: various fixes
Date: Tue, 15 Apr 2014 00:08:47 -0400 (EDT)
Message-ID: <20140415.000847.1023623656391844046.davem@davemloft.net>
References: <1397494082-9394-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de, werner@almesberger.net
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbaDOEIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 00:08:49 -0400
In-Reply-To: <1397494082-9394-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Mon, 14 Apr 2014 18:48:00 +0200

> I currently working on a big cleanup for the at86rf230 and I detect some bugs
> in the current implementation. I will send patch stacks if net-next is open
> again.
> 
> It's funny to find the forgotten shift and mask in the __at86rf230_read_subreg
> function but it only makes trouble if csma is activated that's why it still works
> before for me.

Series applied.
