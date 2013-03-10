From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] bcm63xx_enet: use managed io memory allocations
Date: Sun, 10 Mar 2013 16:57:16 -0400 (EDT)
Message-ID: <20130310.165716.1589865971999552803.davem@davemloft.net>
References: <1362923869-21346-1-git-send-email-jogo@openwrt.org>
	<CAJiQ=7Cz0e2q61X7gsnistP7BB2wv=U-QFoFWGZ+WZgnfzHz0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jogo@openwrt.org, netdev@vger.kernel.org, mbizon@freebox.fr,
	florian@openwrt.org
To: cernekee@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906Ab3CJU5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 16:57:08 -0400
In-Reply-To: <CAJiQ=7Cz0e2q61X7gsnistP7BB2wv=U-QFoFWGZ+WZgnfzHz0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Cernekee <cernekee@gmail.com>
Date: Sun, 10 Mar 2013 12:59:38 -0700

> On Sun, Mar 10, 2013 at 6:57 AM, Jonas Gorski <jogo@openwrt.org> wrote:
>> Signed-off-by: Jonas Gorski <jogo@openwrt.org>
>> ---
>>  drivers/net/ethernet/broadcom/bcm63xx_enet.c |   43 +++++---------------------
>>  1 file changed, 7 insertions(+), 36 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> 
> For the whole series:
> 
> Acked-by: Kevin Cernekee <cernekee@gmail.com>

Series applied to net-next, thanks.
