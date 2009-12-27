From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: use tun_sk instead container_of
Date: Sat, 26 Dec 2009 20:26:12 -0800 (PST)
Message-ID: <20091226.202612.212674239.davem@davemloft.net>
References: <200912252017.43998.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: vgusev@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753570AbZL0E0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 23:26:10 -0500
In-Reply-To: <200912252017.43998.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitaliy Gusev <vgusev@openvz.org>
Date: Fri, 25 Dec 2009 20:17:43 +0300

> Using macro tun_sk is more clear and shorter. However tun.c has tun_sk,
> but doesn't use it. 
> 
> Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

Applied, thanks.
