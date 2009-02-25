From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Remove some pointless conditionals before
 kfree_skb()
Date: Tue, 24 Feb 2009 23:38:39 -0800 (PST)
Message-ID: <20090224.233839.61530822.davem@davemloft.net>
References: <49A3A59D.9090102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760109AbZBYHi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:38:58 -0500
In-Reply-To: <49A3A59D.9090102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 24 Feb 2009 15:45:33 +0800

> Remove some pointless conditionals before kfree_skb().
> 
> The semantic match that finds the problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
 ...
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
