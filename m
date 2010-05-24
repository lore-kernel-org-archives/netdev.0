From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/6] caif: Bugfix - wait_ev*_timeout returns
 long.
Date: Sun, 23 May 2010 23:40:23 -0700 (PDT)
Message-ID: <20100523.234023.186721776.davem@davemloft.net>
References: <1274444172-31969-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjurbr@gmail.com,
	linus.walleij@stericsson.com, marcel@holtmann.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60431
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755808Ab0EXGkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:40:13 -0400
In-Reply-To: <1274444172-31969-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Fri, 21 May 2010 14:16:07 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Discovered bug when testing on 64bit architecture.
> Fixed by using long to store result from wait_event_interruptible_timeout.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
