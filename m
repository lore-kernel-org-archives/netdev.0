From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/4] tcp: use TCP_BASE_MSS to set basic mss value
Date: Thu, 02 Dec 2010 13:28:04 -0800 (PST)
Message-ID: <20101202.132804.35033603.davem@davemloft.net>
References: <4CF71AE2.6050406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45234
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757677Ab0LBV1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 16:27:37 -0500
In-Reply-To: <4CF71AE2.6050406@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 02 Dec 2010 12:04:50 +0800

> 
> TCP_BASE_MSS is defined, but not used.
> commit 5d424d5a introduce this macro, so use
> it to initial sysctl_tcp_base_mss.
> 
> commit 5d424d5a674f782d0659a3b66d951f412901faee
> Author: John Heffner <jheffner@psc.edu>
> Date:   Mon Mar 20 17:53:41 2006 -0800
> 
>     [TCP]: MTU probing
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---

Applied.
