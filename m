From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 21 Nov 2013 10:38:42 -0800
Message-ID: <1385059122.10637.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131121.132912.1559687338397588769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, christoph.paasch@uclouvain.be,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:41038 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab3KUSoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:44:22 -0500
Received: by mail-yh0-f52.google.com with SMTP id i72so3629709yha.39
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 10:44:21 -0800 (PST)
In-Reply-To: <20131121.132912.1559687338397588769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 13:29 -0500, David Miller wrote:
> Eric please resubmit this in the future once all of the other fixes
> have been sorted out with Herbert.

Sure, I postponed this for net-next, and will remove the GRO part from
it, as Herbert choked on it ;)
