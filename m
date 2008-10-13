From: David Miller <davem@davemloft.net>
Subject: Re: qlge: remove duplicated #include
Date: Sun, 12 Oct 2008 21:04:17 -0700 (PDT)
Message-ID: <20081012.210417.245648642.davem@davemloft.net>
References: <20081012171458.F6D4.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, ron.mercer@qlogic.com,
	netdev@vger.kernel.org
To: weiyi.huang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46845
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750783AbYJMEEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 00:04:41 -0400
In-Reply-To: <20081012171458.F6D4.WEIYI.HUANG@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huang Weiyi <weiyi.huang@gmail.com>
Date: Sun, 12 Oct 2008 17:23:24 +0800

> Removed duplicated include <linux/init.h> in files below
>   drivers/net/qlge/qlge_ethtool.c
>   drivers/net/qlge/qlge_main.c
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

Applied, thanks.
