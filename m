From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: reduce USB network driver config
 options.
Date: Tue, 05 Aug 2014 16:49:26 -0700 (PDT)
Message-ID: <20140805.164926.787486099717166994.davem@davemloft.net>
References: <20140805211052.GA29600@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbaHEXt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:49:27 -0400
In-Reply-To: <20140805211052.GA29600@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 5 Aug 2014 23:10:52 +0200

> From: Francois Romieu <romieu@fr.zoreil.com>
> 
> USB network drivers are already handled in drivers/net/usb/Kconfig.
> Let's save the maintenance burden of dependencies in drivers/net/Makefile.
> 
> The newly introduced USB_NET_DRIVERS umbrella config option defaults
> to 'y' so as to minimize the changes of behavior.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Looks great, applied, thanks!
