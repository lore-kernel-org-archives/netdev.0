From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/6] Calxeda xgmac performance fixes
Date: Wed, 07 Nov 2012 03:52:50 -0500 (EST)
Message-ID: <20121107.035250.1188301135502258324.davem@davemloft.net>
References: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rob.herring@calxeda.com
To: robherring2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab2KGIww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 03:52:52 -0500
In-Reply-To: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <robherring2@gmail.com>
Date: Mon,  5 Nov 2012 10:22:18 -0600

> This is a series of performance improvements to the xgmac driver. The
> most significant changes are the alignment fixes to avoid alignment
> traps on received frames and using raw i/o accessors.

All applied to net-next, thanks.
