From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 76] drivers/net/via-velocity.c: mostly kmalloc + memset conversion to kcalloc
Date: Wed, 1 Aug 2007 00:32:47 +0200
Message-ID: <20070731223247.GA22528@electric-eye.fr.zoreil.com>
References: <200707311845.48807.m.kozlowski@tuxland.pl> <200708010011.50979.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38828 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755590AbXGaWfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 18:35:01 -0400
Content-Disposition: inline
In-Reply-To: <200708010011.50979.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mariusz Kozlowski <m.kozlowski@tuxland.pl> :
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  drivers/net/via-velocity.c | 88263 -> 88120 (-143 bytes)
>  drivers/net/via-velocity.o | 254264 -> 253828 (-436 bytes)
> 
>  drivers/net/via-velocity.c |   24 ++++++++++--------------
>  1 file changed, 10 insertions(+), 14 deletions(-)

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

-- 
Ueimor
