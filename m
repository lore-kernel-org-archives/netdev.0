From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: remove some pointless conditionals before
 kfree_skb()
Date: Thu, 26 Feb 2009 23:08:44 -0800 (PST)
Message-ID: <20090226.230844.136367295.davem@davemloft.net>
References: <49A51BF1.2030503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kas@fi.muni.cz, jgarzik@pobox.com, netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754925AbZB0HJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 02:09:00 -0500
In-Reply-To: <49A51BF1.2030503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Wed, 25 Feb 2009 18:22:41 +0800

> Remove some pointless conditionals before kfree_skb().
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
