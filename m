From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8021q: update description
Date: Tue, 21 Jan 2014 17:02:13 -0800 (PST)
Message-ID: <20140121.170213.1340386947684240946.davem@davemloft.net>
References: <1390211379-3374-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbaAVBCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 20:02:14 -0500
In-Reply-To: <1390211379-3374-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yegorslists@googlemail.com
Date: Mon, 20 Jan 2014 10:49:39 +0100

> From: Yegor Yefremov <yegorslists@googlemail.com>
> 
> Replace deprecated 'vconfig' tool with 'ip' from 'iproute2'. Add
> some beautifications like replacing 'ethernet' with 'Ethernet' and
> removing unneeded spaces.
> 
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

Applied.

 ...
>  	  <http://www.candelatech.com/~greear/vlan.html>

We should also probably get rid of this URL reference, it hasn't been
updated in almost 9 years, talks about 2.2 and 2.4.x kernels, and
recommends using vconfig.
