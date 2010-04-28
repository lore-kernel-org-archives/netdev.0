From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 5/7] caif: Rewritten socket implementation
Date: Wed, 28 Apr 2010 13:03:20 -0700 (PDT)
Message-ID: <20100428.130320.233677548.davem@davemloft.net>
References: <1272480880-30672-3-git-send-email-sjur.brandeland@stericsson.com>
	<1272480880-30672-4-git-send-email-sjur.brandeland@stericsson.com>
	<1272480880-30672-5-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, sjurbr@gmail.com,
	linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57279
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932109Ab0D1UDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 16:03:14 -0400
In-Reply-To: <1272480880-30672-5-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Wed, 28 Apr 2010 20:54:38 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Changes:
>  This is a complete re-write of the socket layer. Making the socket
>  implementation more aligned with the other socket layers and using more
>  of the support functions available in sock.c. Lots of code is copied
>  from af_unix (and some from af_irda).
>  Non-blocking mode should be working as well.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
