From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: drivers/net/phy/marvell.c: 88e1111 can't get out sleep mode
Date: Mon, 29 Sep 2008 15:45:40 +0100
Message-ID: <1222699540.4579.7.camel@achroite>
References: <20080929133305.GA10554@debian>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jeff@garzik.org>,
	Alexandr Smirnov <asmirnov@ru.mvista.com>
To: Wang Jian <lark@linux.net.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35038 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751682AbYI2Oqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 10:46:51 -0400
In-Reply-To: <20080929133305.GA10554@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-09-29 at 21:33 +0800, Wang Jian wrote:
> Hi,
> 
> During my testing, I found that 88e1111 can't get out of sleep mode
> (Energy detect+) in certain condition.
[...]

We had the same problem with development boards using that PHY and we
stopped using the energy detect mode.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

