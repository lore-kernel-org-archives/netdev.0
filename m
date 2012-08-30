From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2]: ieee802154 drivers location
Date: Thu, 30 Aug 2012 13:24:52 -0400 (EDT)
Message-ID: <20120830.132452.904626051029519065.davem@davemloft.net>
References: <1345993811-13803-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab2H3RYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:24:54 -0400
In-Reply-To: <1345993811-13803-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Sun, 26 Aug 2012 19:10:09 +0400

> Please review these two patches:
> 
> 1. I want to keep 'ieee802154' drivers with other networking code in
>    'drivers/net' folder instead of current location in drivers root.
>    I don't exactly know this historical reason, but lets keep networking
>    code together.
> 2. Minor cosmetic improvement in at86rf230 driver

Both applied to net-next, thanks.
