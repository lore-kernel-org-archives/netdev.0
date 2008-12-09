From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH1/1] hso modem detect fix patch against Alan Cox'es tty
 tree
Date: Tue, 09 Dec 2008 15:53:26 -0800 (PST)
Message-ID: <20081209.155326.165422892.davem@davemloft.net>
References: <493D3167.200@option.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: D.Barow@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39449
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751073AbYLIXxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 18:53:25 -0500
In-Reply-To: <493D3167.200@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Joseph Barrow <D.Barow@option.com>
Date: Mon, 08 Dec 2008 15:38:31 +0100

> Fixed incorrect check for the modem port, this prevents
> crashes caused by issueing a tiocmget_submit_urb
> on endpoints which don't exist for non modem devices. 
>
> Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>

Alan, you got this one or want me to grab it?

I'm fine either way.
