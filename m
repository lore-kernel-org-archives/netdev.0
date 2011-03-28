From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tg3: Fix inline keyword usage
Date: Sun, 27 Mar 2011 18:39:02 -0700 (PDT)
Message-ID: <20110327.183902.212698820.davem@davemloft.net>
References: <1301193753-10045-1-git-send-email-martinez.javier@gmail.com>
	<1301193753-10045-3-git-send-email-martinez.javier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: martinez.javier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54541
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753379Ab1C1Bjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:39:40 -0400
In-Reply-To: <1301193753-10045-3-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Martinez Canillas <martinez.javier@gmail.com>
Date: Sun, 27 Mar 2011 04:42:33 +0200

> The correct usage is "static inline void" not "static void inline".
> 
> Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>

Applied.
