From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.22-rc4] UDP's local port assignment not working correctly.
Date: Thu, 07 Jun 2007 13:23:39 -0700 (PDT)
Message-ID: <20070607.132339.82695611.davem@davemloft.net>
References: <200706072040.BEC00116.MQFFtSOVOHFOLJ@I-love.SAKURA.ne.jp>
	<20070607151839.d8f1c164.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43032
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762479AbXFGUXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 16:23:24 -0400
In-Reply-To: <20070607151839.d8f1c164.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 7 Jun 2007 15:18:39 +0200

> Yes, this was discovered two days ago and David reverted four commits.
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=82c5fde20031375cd93fa5a247cf15603ea1f152
> 
> So it should probably be included in Linus tree very very soon.

Right.
