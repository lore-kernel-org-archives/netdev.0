From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: drivers/net/phy/marvell.c: 88e1111 can't get out sleep mode
Date: Mon, 29 Sep 2008 17:55:08 +0100
Message-ID: <1222707308.3984.27.camel@achroite>
References: <20080929133305.GA10554@debian>
	 <1222699540.4579.7.camel@achroite>  <48E1022A.4000308@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jeff@garzik.org>,
	Alexandr Smirnov <asmirnov@ru.mvista.com>
To: Wang Jian <lark@linux.net.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:45570 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750819AbYI2Q64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 12:58:56 -0400
In-Reply-To: <48E1022A.4000308@linux.net.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-09-30 at 00:28 +0800, Wang Jian wrote:
> According to datasheet, fiber/copper auto detect & auto switch depend on
> energy detect.
> 
> Or I misunderstand DIS_FC & DIS_SLEEP? When DIS_SLEEP is set, fiber/copper
> auto detect & auto switch still work?
[...]

I've no idea; we only ever used copper.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

