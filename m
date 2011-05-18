From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with a 'bitwise'
 type
Date: Tue, 17 May 2011 22:01:01 -0400
Message-ID: <4DD3285D.6010506@garzik.org>
References: <1305658121.2848.29.camel@bwh-desktop> <20110517.152651.1785846817320651943.davem@davemloft.net> <1305666379.2848.45.camel@bwh-desktop> <20110517.171412.1017451005914294196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:36876 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932434Ab1ERCBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 22:01:03 -0400
Received: by yxs7 with SMTP id 7so390806yxs.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 19:01:03 -0700 (PDT)
In-Reply-To: <20110517.171412.1017451005914294196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2011 05:14 PM, David Miller wrote:
> Accept that the compiler currently doesn't want to allow enums to be
> used as bit-masks, don't paper around it.

This practice is all over the kernel.

It's a bit silly to make such a big deal, because of that.

	Jeff


