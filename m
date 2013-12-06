From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/9] vti4: prepare namespace and interfamily
 support.
Date: Fri, 06 Dec 2013 15:20:31 -0500 (EST)
Message-ID: <20131206.152031.319788789530762875.davem@davemloft.net>
References: <20131205120028.GW31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christophe.gouault@6wind.com,
	saurabh.mohan@vyatta.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758737Ab3LFUUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 15:20:33 -0500
In-Reply-To: <20131205120028.GW31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 5 Dec 2013 13:00:28 +0100

> The patchset that implements an IPsec protocol multiplexer, so that vti
> can register it's own receive path hooks. Further it makes the i_key
> usable for vti and changes the vti4 code to do the following:
> 
> vti uses the IPsec protocol multiplexer to register it's
> own receive side hooks for ESP and AH.

I have no fundamental objections to this series, looks good.
