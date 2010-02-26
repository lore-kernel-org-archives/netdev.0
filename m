From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/7] drivers/net/myri10ge: Use pr_<level> and
 netdev_<level>
Date: Fri, 26 Feb 2010 01:40:16 -0800 (PST)
Message-ID: <20100226.014016.200109230.davem@davemloft.net>
References: <cover.1266893507.git.joe@perches.com>
	<0a98bb59c8ba36ea37bac53137e2b594bbc984d8.1266893507.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com, brice@myri.com,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40477
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935755Ab0BZJj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:39:58 -0500
In-Reply-To: <0a98bb59c8ba36ea37bac53137e2b594bbc984d8.1266893507.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 22 Feb 2010 18:56:58 -0800

> Add #define pr_fmt(fmt)
> Convert logging messages to pr_<level> and netdev_<level>
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
