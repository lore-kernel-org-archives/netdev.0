From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: bcmsysport: utilize newer NAPI APIs
Date: Thu, 21 Apr 2016 15:06:32 -0400 (EDT)
Message-ID: <20160421.150632.2256057262499167758.davem@davemloft.net>
References: <1461177429-23553-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, pgynther@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbcDUTGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:06:34 -0400
In-Reply-To: <1461177429-23553-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 20 Apr 2016 11:37:07 -0700

> These two patches are very analoguous to what was already submitted for
> BCMGENET and switch the SYSTEMPORT driver to utilizing __napi_schedule_irqoff()
> and napi_complete_done for the RX NAPI context.

Applied, thanks.
