From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] netdev: bfin_mac: handle timeouts with the MDIO
 registers gracefully
Date: Mon, 17 May 2010 17:22:06 -0700 (PDT)
Message-ID: <20100517.172206.179930115.davem@davemloft.net>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
	<1273505954-32588-8-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43062
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755919Ab0ERAV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:21:58 -0400
In-Reply-To: <1273505954-32588-8-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 10 May 2010 11:39:13 -0400

> Have the low level MDIO functions pass back up timeout information so we
> don't waste time polling them multiple times when there is a problem, and
> so we don't let higher layers think the device is available when it isn't.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
