From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/3] ethernet: arc: remove use of 'struct
 platform_device'
Date: Wed, 27 Aug 2014 16:40:41 -0700 (PDT)
Message-ID: <20140827.164041.1199150301507774917.davem@davemloft.net>
References: <1409058891-30790-1-git-send-email-romain.perier@gmail.com>
	<3908582.WSyTHHYM5g@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romain.perier@gmail.com, heiko@sntech.de, tklauser@distanz.ch,
	b.galvani@gmail.com, eric.dumazet@gmail.com,
	yongjun_wei@trendmicro.com.cn, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935743AbaH0Xkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 19:40:43 -0400
In-Reply-To: <3908582.WSyTHHYM5g@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 26 Aug 2014 15:30:19 +0200

> On Tuesday 26 August 2014 13:14:49 Romain Perier wrote:
>> This is a preparation of an api changes for the emac_main.c module.
>> The involved functions are arc_emac_probe and arc_emac_remove.
>> 
>> Signed-off-by: Romain Perier <romain.perier@gmail.com>
>> 
> 
> All three patches:
> 
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>

Series applied to net-next, thanks.
