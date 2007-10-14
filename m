From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] tc35815: remove redefinition of lp
Date: Mon, 15 Oct 2007 01:31:05 +0900 (JST)
Message-ID: <20071015.013105.126573780.anemo@mba.ocn.ne.jp>
References: <20071014153555.6ad676d8.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: yoichi_yuasa@tripeaks.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:55264 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753148AbXJNRLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Oct 2007 13:11:22 -0400
In-Reply-To: <20071014153555.6ad676d8.yoichi_yuasa@tripeaks.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 14 Oct 2007 15:35:55 +0900, Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp> wrote:
> Remove redefinition of lp in tc35815.c.
> 
> drivers/net/tc35815.c: In function 'tc35815_interrupt':
> drivers/net/tc35815.c:1464: error: redefinition of 'lp'
> drivers/net/tc35815.c:1443: error: previous definition of 'lp' was here
> 
> Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

Thanks!

Acked-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
