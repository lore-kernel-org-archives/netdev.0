From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sh-eth: Add support selecting MII function for
 SH7734 and R8A7740
Date: Mon, 11 Jun 2012 16:47:17 -0700 (PDT)
Message-ID: <20120611.164717.1390327462404819704.davem@davemloft.net>
References: <1339135311-1896-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942Ab2FKXrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 19:47:18 -0400
In-Reply-To: <1339135311-1896-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Fri,  8 Jun 2012 15:01:51 +0900

> +	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) */

Nothing tests this value.
