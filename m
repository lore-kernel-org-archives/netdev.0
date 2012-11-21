From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bonding: Bonding driver does not consider the
 gso_max_size/gso_max_segs setting of slave devices.
Date: Wed, 21 Nov 2012 11:51:24 -0500 (EST)
Message-ID: <20121121.115124.1062713458949050915.davem@davemloft.net>
References: <649de771-427a-4876-af3c-9f84a164a7f1@CMEXHTCAS2.ad.emulex.com>
	<1353509706.2590.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sarveshwar.bandi@emulex.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328Ab2KUQv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 11:51:26 -0500
In-Reply-To: <1353509706.2590.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Nov 2012 06:55:06 -0800

> On Wed, 2012-11-21 at 20:05 +0530, sarveshwar.bandi@emulex.com wrote:
>> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
>> 
>> Patch sets the lowest gso_max_size and gso_max_segs values of the slave devices during enslave and detach.
>> 
>> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
