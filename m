From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch 2/2]r8169: remove redundant RTL_W32
Date: Thu, 03 Jun 2010 13:40:10 +0100
Message-ID: <1275568810.2870.90.camel@localhost>
References: <20100603112721.GD24909@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, davem@davemloft.net, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49397 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621Ab0FCMkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 08:40:15 -0400
In-Reply-To: <20100603112721.GD24909@host-a-55.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-03 at 19:27 +0800, Junchang Wang wrote:
> Writting "cmd" into "CounterAddrLow" twice is redundant.
[...]

I assume you've checked this against the datasheets for all 20 variants
of this hardware?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

