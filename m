From: David Miller <davem@davemloft.net>
Subject: Re: v4 [PATCH 5/9] ipv6: Fix using after dev_put()
Date: Mon, 14 Jul 2008 20:55:01 -0700 (PDT)
Message-ID: <20080714.205501.26863325.davem@davemloft.net>
References: <487C0ABA.1070506@cn.fujitsu.com>
	<487C1291.6050107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48638
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753626AbYGODzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:55:00 -0400
In-Reply-To: <487C1291.6050107@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 15 Jul 2008 10:59:29 +0800

> Patrick McHardy pointed out it.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks.
