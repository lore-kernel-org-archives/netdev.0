From: David Miller <davem@davemloft.net>
Subject: Re: [patch 06/21] cassini: use request_firmware
Date: Mon, 22 Sep 2008 19:27:26 -0700 (PDT)
Message-ID: <20080922.192726.220130076.davem@davemloft.net>
References: <200809222152.m8MLqEIW031952@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, jaswinder@infradead.org,
	dwmw2@infradead.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60088
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754009AbYIWC1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:27:38 -0400
In-Reply-To: <200809222152.m8MLqEIW031952@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:52:13 -0700

> Firmware blob looks like this...
>         __le16 load_address
>         unsigned char data[]
> 
> [akpm@linux-foundation.org: include vmalloc.h]
> Signed-off-by: Jaswinder Singh <jaswinder@infradead.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-next-2.6
