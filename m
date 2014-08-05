From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: Simplify return path of team_newlink
Date: Tue, 05 Aug 2014 16:38:09 -0700 (PDT)
Message-ID: <20140805.163809.1291091788473821975.davem@davemloft.net>
References: <1407221930-15590-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbaHEXiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:38:10 -0400
In-Reply-To: <1407221930-15590-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue,  5 Aug 2014 15:58:50 +0900

> The variable "err" is not necessary.
> Return register_netdevice() directly.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied, thanks.
