From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] skge: Remove tx queue stopping in skge_devinit()
Date: Mon, 08 Nov 2010 12:19:13 -0800 (PST)
Message-ID: <20101108.121913.112596741.davem@davemloft.net>
References: <1289061572-5029-1-git-send-email-guichaz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: guichaz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754380Ab0KHUSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 15:18:49 -0500
In-Reply-To: <1289061572-5029-1-git-send-email-guichaz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Chazarain <guichaz@gmail.com>
Date: Sat,  6 Nov 2010 17:39:31 +0100

> After e6484930d7c73d324bccda7d43d131088da697b9: net: allocate tx queues in register_netdevice
> It causes an Oops at skge_probe() time.
> 
> Signed-off-by: Guillaume Chazarain <guichaz@gmail.com>

Applied.
