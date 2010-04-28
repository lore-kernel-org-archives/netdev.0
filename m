From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 6/7] caif: Bugfixes in CAIF netdevice for
 close and flow control
Date: Wed, 28 Apr 2010 13:03:26 -0700 (PDT)
Message-ID: <20100428.130326.02298163.davem@davemloft.net>
References: <1272480880-30672-4-git-send-email-sjur.brandeland@stericsson.com>
	<1272480880-30672-5-git-send-email-sjur.brandeland@stericsson.com>
	<1272480880-30672-6-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, sjurbr@gmail.com,
	linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40782
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932109Ab0D1UDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 16:03:20 -0400
In-Reply-To: <1272480880-30672-6-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Wed, 28 Apr 2010 20:54:39 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Changes:
> o Bugfix: Flow control was causing the device to be destroyed.
> o Bugfix: Handle CAIF channel connect failures.
> o If the underlying link layer is gone the net-device is no longer removed,
>   but closed.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
