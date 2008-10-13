From: David Miller <davem@davemloft.net>
Subject: Re: jme: remove unused #include <version.h>
Date: Sun, 12 Oct 2008 21:09:11 -0700 (PDT)
Message-ID: <20081012.210911.59602870.davem@davemloft.net>
References: <20081012231101.E7EF.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org
To: weiyi.huang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752192AbYJMEJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 00:09:35 -0400
In-Reply-To: <20081012231101.E7EF.WEIYI.HUANG@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huang Weiyi <weiyi.huang@gmail.com>
Date: Sun, 12 Oct 2008 23:12:54 +0800

> The file(s) below do not use LINUX_VERSION_CODE nor KERNEL_VERSION.
>   drivers/net/jme.c
> 
> This patch removes the said #include <version.h>.
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

Applied, thanks.
