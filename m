From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn/hisax: hex vs decimal typo in prfeatureind()
Date: Thu, 06 Feb 2014 20:40:07 -0800 (PST)
Message-ID: <20140206.204007.2254644541681384666.davem@davemloft.net>
References: <20140206080308.GB26661@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, akpm@linux-foundation.org,
	keescook@chromium.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbaBGEkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 23:40:08 -0500
In-Reply-To: <20140206080308.GB26661@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 6 Feb 2014 11:03:08 +0300

> This is a static checker fix, but judging from the context then I think
> hexidecimal 0x80 is intended here instead of decimal 80.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
