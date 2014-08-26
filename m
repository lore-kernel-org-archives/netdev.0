From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 1/3] ethernet: arc: remove use of 'struct platform_device'
Date: Tue, 26 Aug 2014 15:30:19 +0200
Message-ID: <3908582.WSyTHHYM5g@wuerfel>
References: <1409058891-30790-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, heiko@sntech.de, tklauser@distanz.ch,
	b.galvani@gmail.com, eric.dumazet@gmail.com,
	yongjun_wei@trendmicro.com.cn, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:58130 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475AbaHZNag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 09:30:36 -0400
In-Reply-To: <1409058891-30790-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 August 2014 13:14:49 Romain Perier wrote:
> This is a preparation of an api changes for the emac_main.c module.
> The involved functions are arc_emac_probe and arc_emac_remove.
> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>
> 

All three patches:

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
