From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] netdev: bfin_mac: clear RXCKS if hardware
 generated checksum is not enabled
Date: Mon, 17 May 2010 17:21:51 -0700 (PDT)
Message-ID: <20100517.172151.246539346.davem@davemloft.net>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
	<1273505954-32588-5-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43044
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752090Ab0ERAVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:21:42 -0400
In-Reply-To: <1273505954-32588-5-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 10 May 2010 11:39:10 -0400

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> Otherwise we might be get a setting mismatch from a previous module or
> bootloader and what the driver currently expects.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
