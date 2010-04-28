From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/7] caif: Ldisc add permission check and
 mem-alloc error check
Date: Wed, 28 Apr 2010 13:02:59 -0700 (PDT)
Message-ID: <20100428.130259.116357990.davem@davemloft.net>
References: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, sjurbr@gmail.com,
	linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932109Ab0D1UCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 16:02:54 -0400
In-Reply-To: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Wed, 28 Apr 2010 20:54:34 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Changes:
>    o Added permission checks for installing. CAP_SYS_ADMIN and
>      CAP_SYS_TTY_CONFIG can install the ldisc.
>    o Check if allocation of skb was successful.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
