From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND -v2 2/2] net/7990: Make lance_private.name const
Date: Sun, 29 Dec 2013 00:47:19 -0500 (EST)
Message-ID: <20131229.004719.1062885024562611557.davem@davemloft.net>
References: <1388261475-7332-1-git-send-email-geert@linux-m68k.org>
	<1388261475-7332-2-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716Ab3L2FrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 00:47:20 -0500
In-Reply-To: <1388261475-7332-2-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sat, 28 Dec 2013 21:11:15 +0100

> This allows to drop a few casts.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Also applied, thanks a lot.
