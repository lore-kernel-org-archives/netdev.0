From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [2.6 patch] drivers/net/ipg.c: add __devexit annotation
Date: Wed, 12 Dec 2007 00:59:47 +0100
Message-ID: <20071211235947.GA30456@electric-eye.fr.zoreil.com>
References: <20071211222030.GD14204@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sorbica@icplus.com.tw, jesse@icplus.com.tw, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60865 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752816AbXLLAGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 19:06:33 -0500
Content-Disposition: inline
In-Reply-To: <20071211222030.GD14204@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk <bunk@kernel.org> :
> ipg_remove() can become __devexit.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

I'll add it to the pending ipg queue.

-- 
Ueimor
