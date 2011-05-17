From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with a
 'bitwise' type
Date: Tue, 17 May 2011 14:22:58 -0700
Message-ID: <1305667378.1722.65.camel@Joe-Laptop>
References: <1305658121.2848.29.camel@bwh-desktop>
	 <20110517.152651.1785846817320651943.davem@davemloft.net>
	 <1305666379.2848.45.camel@bwh-desktop>
	 <20110517.171412.1017451005914294196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1726 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932075Ab1EQVXA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 17:23:00 -0400
In-Reply-To: <20110517.171412.1017451005914294196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 17:14 -0400, David Miller wrote:
> Accept that the compiler currently doesn't want to allow enums to be
> used as bit-masks, don't paper around it.

A patch applied yesterday using enums as bitmasks:
http://patchwork.ozlabs.org/patch/95802/


