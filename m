From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] 6lowpan: udp compression/uncompression fix
Date: Thu, 14 Nov 2013 17:06:20 -0500 (EST)
Message-ID: <20131114.170620.830861106940917404.davem@davemloft.net>
References: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
	<1384445983.28716.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.aring@gmail.com, alex.bluesman.smirnov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	jukka.rissanen@linux.intel.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755273Ab3KNWGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 17:06:23 -0500
In-Reply-To: <1384445983.28716.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Nov 2013 08:19:43 -0800

> On Thu, 2013-11-14 at 16:48 +0100, Alexander Aring wrote:
>> The current 6LoWPAN udp compression/uncompression is completely broken.
>> This patch series fix a lot of udp compression/uncompression issues and
>> add support parsing with lowpan_fetch_skb function.
> 
> If its broken, why targeting net-next tree (which is closed BTW ATM) ?

In any event, if you do want it to go into net-next, please resubmit
this series when the net-next tree opens back up after the merge
window.

Thanks!
