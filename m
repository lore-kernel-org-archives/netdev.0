From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] core: remove pointless conditional before kfree()
Date: Tue, 31 Mar 2009 15:06:33 -0700 (PDT)
Message-ID: <20090331.150633.99304989.davem@davemloft.net>
References: <49D1CFAF.4030109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755408AbZCaWGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 18:06:44 -0400
In-Reply-To: <49D1CFAF.4030109@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 31 Mar 2009 16:09:19 +0800

> Remove pointless conditional before kfree().
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied, thanks.
