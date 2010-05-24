From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 3/6] caif: Bugfix - handle mem-allocation
 failures
Date: Sun, 23 May 2010 23:40:33 -0700 (PDT)
Message-ID: <20100523.234033.234327579.davem@davemloft.net>
References: <1274444172-31969-1-git-send-email-sjur.brandeland@stericsson.com>
	<1274444172-31969-2-git-send-email-sjur.brandeland@stericsson.com>
	<1274444172-31969-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjurbr@gmail.com,
	linus.walleij@stericsson.com, marcel@holtmann.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60444
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755936Ab0EXGkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:40:23 -0400
In-Reply-To: <1274444172-31969-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Fri, 21 May 2010 14:16:09 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Discovered bugs when injecting slab allocation failures.
> Add checks on all memory allocation.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
