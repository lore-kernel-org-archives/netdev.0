From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: hisax: add missing usb_free_urb
Date: Tue, 26 Feb 2013 17:35:01 -0500 (EST)
Message-ID: <20130226.173501.222300885333128722.davem@davemloft.net>
References: <1361867210-13309-1-git-send-email-makienko@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	ldv-project@linuxtesting.org
To: makienko@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053Ab3BZWfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 17:35:03 -0500
In-Reply-To: <1361867210-13309-1-git-send-email-makienko@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marina Makienko <makienko@ispras.ru>
Date: Tue, 26 Feb 2013 12:26:50 +0400

> Add missing usb_free_urb() on failure path in st5481_setup_usb().
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Marina Makienko <makienko@ispras.ru>

Applied, thanks.
