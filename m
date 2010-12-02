From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/4] ipv6: use ND_REACHABLE_TIME and
 ND_RETRANS_TIMER instead of magic number
Date: Thu, 02 Dec 2010 13:28:09 -0800 (PST)
Message-ID: <20101202.132809.15247979.davem@davemloft.net>
References: <4CF71AF8.9050205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757995Ab0LBV1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 16:27:43 -0500
In-Reply-To: <4CF71AF8.9050205@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Thu, 02 Dec 2010 12:05:12 +0800

> 
> ND_REACHABLE_TIME and ND_RETRANS_TIMER have defined 
> since v2.6.12-rc2, but never been used.
> So use them instead of magic number.
> 
> This patch also changes original code style to read comfortably .
> 
> Thank YOSHIFUJI Hideaki for pointing it out.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
