From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: add GRO support
Date: Sat, 21 Apr 2012 16:44:01 -0400 (EDT)
Message-ID: <20120421.164401.2058732185459124472.davem@davemloft.net>
References: <1334912075-27073-1-git-send-email-b06378@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: b06378@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354Ab2DUUqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 16:46:10 -0400
In-Reply-To: <1334912075-27073-1-git-send-email-b06378@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiajun Wu <b06378@freescale.com>
Date: Fri, 20 Apr 2012 16:54:35 +0800

> Replace netif_receive_skb with napi_gro_receive.
> 
> Signed-off-by: Jiajun Wu <b06378@freescale.com>

Applied.
