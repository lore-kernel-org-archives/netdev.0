From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] make cadence ethernet drivers build on any
 architecture
Date: Tue, 23 Oct 2012 02:40:44 -0400 (EDT)
Message-ID: <20121023.024044.1356362357417321521.davem@davemloft.net>
References: <1350931534-8416-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, hskinnemoen@gmail.com,
	egtvedt@samfundet.no, plagnioj@jcrosoft.com, bgat@billgatliff.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab2JWGkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:40:46 -0400
In-Reply-To: <1350931534-8416-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Mon, 22 Oct 2012 20:45:30 +0200

> Joachim Eastwood (4):
>   net/macb: fix truncate warnings
>   net/cadence: get rid of HAVE_NET_MACB
>   net/at91_ether: select MACB in Kconfig
>   net/at91_ether: add pdata flag for reverse Eth addr

All applied to net-next, thanks a lot.
