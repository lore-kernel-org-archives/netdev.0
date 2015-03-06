From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: gro: remove obsolete code from
 skb_gro_receive()
Date: Fri, 06 Mar 2015 12:39:48 -0800
Message-ID: <1425674388.18614.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425493600.5130.208.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425592068.5130.266.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150306.010441.1755035570297062470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:39353 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032AbbCFUju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 15:39:50 -0500
Received: by iecat20 with SMTP id at20so35262487iec.6
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 12:39:50 -0800 (PST)
In-Reply-To: <20150306.010441.1755035570297062470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-06 at 01:04 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>

> > v2: removed headroom & nskb variables, no longer needed.
> 
> Looks good, applied, thanks!

Strange, I do not see it on net-next ?
