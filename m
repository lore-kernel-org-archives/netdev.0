From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fec: Add support for reading RMON registers
Date: Wed, 26 Jun 2013 15:46:15 -0700 (PDT)
Message-ID: <20130626.154615.144627726991411622.davem@davemloft.net>
References: <1372227532-27467-1-git-send-email-cphealy@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, fabio.estevam@freescale.com,
	linux@roeck-us.net, rsushko@gmail.com, netdev@vger.kernel.org
To: cphealy@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab3FZWqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:46:16 -0400
In-Reply-To: <1372227532-27467-1-git-send-email-cphealy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Healy <cphealy@gmail.com>
Date: Tue, 25 Jun 2013 23:18:52 -0700

> Add ethtool operation to read RMON registers.
> 
> Tested against net-next on i.MX28.
> 
> v2: make conditional on #ifndef CONFIG_M5272
> 
> Signed-off-by: Chris Healy <cphealy@gmail.com>

Applied, thanks.
