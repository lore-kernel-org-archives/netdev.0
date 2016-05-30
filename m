From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ieee802154: fix logic error in
 ieee802154_llsec_parse_dev_addr
Date: Sun, 29 May 2016 22:36:36 -0700 (PDT)
Message-ID: <20160529.223636.1598569609362802677.davem@davemloft.net>
References: <7c36848d-28b5-87cc-f998-53cc2428a0a6@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aar@pengutronix.de, linux-wpan@vger.kernel.org,
	netdev@vger.kernel.org
To: sploving1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753773AbcE3Fgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 01:36:37 -0400
In-Reply-To: <7c36848d-28b5-87cc-f998-53cc2428a0a6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baozeng Ding <sploving1@gmail.com>
Date: Thu, 26 May 2016 21:07:42 +0800

> Fix a logic error to avoid potential null pointer dereference.
> 
> Signed-off-by: Baozeng Ding <sploving1@gmail.com>

Applied.
