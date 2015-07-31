From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] br2684: Remove unnecessary formatting macros b1 and bs
Date: Fri, 31 Jul 2015 15:26:06 -0700 (PDT)
Message-ID: <20150731.152606.903585206259906467.davem@davemloft.net>
References: <1438325668.19675.54.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbbGaW0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:26:07 -0400
In-Reply-To: <1438325668.19675.54.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 30 Jul 2015 23:54:28 -0700

> Use vsprintf extension %pI4 instead.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
