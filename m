From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 4/4] caif: Add debug connection type for
 CAIF.
Date: Sun, 20 Jun 2010 20:39:08 -0700 (PDT)
Message-ID: <20100620.203908.35022785.davem@davemloft.net>
References: <1276793741-20278-2-git-send-email-sjur.brandeland@stericsson.com>
	<1276793741-20278-3-git-send-email-sjur.brandeland@stericsson.com>
	<1276793741-20278-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjurbr@gmail.com, netdev@vger.kernel.org,
	linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46946
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757408Ab0FUDi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 23:38:56 -0400
In-Reply-To: <1276793741-20278-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Thu, 17 Jun 2010 18:55:41 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Added new CAIF protocol type CAIFPROTO_DEBUG for accessing
> CAIF debug on the ST Ericsson modems.
> 
> There are two debug servers on the modem, one for radio related
> debug (CAIF_RADIO_DEBUG_SERVICE) and the other for
> communication/application related debug (CAIF_COM_DEBUG_SERVICE).
> 
> The debug connection can contain trace debug printouts or
> interactive debug used for debugging and test.
> 
> Debug connections can be of type STREAM or SEQPACKET.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
