From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Remove debug macro of TCP_CHECK_TIMER
Date: Sun, 20 Feb 2011 11:10:40 -0800 (PST)
Message-ID: <20110220.111040.112609363.davem@davemloft.net>
References: <4D60C901.8050307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@trash.net
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42344
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754640Ab1BTTKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 14:10:04 -0500
In-Reply-To: <4D60C901.8050307@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Sun, 20 Feb 2011 15:55:45 +0800

> 
> Now, TCP_CHECK_TIMER is not used for debuging, it does nothing.
> And, it has been there for several years, maybe 6 years.
> 
> Remove it to keep code clearer.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
