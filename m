From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Thu, 16 Oct 2008 22:23:03 -0700 (PDT)
Message-ID: <20081016.222303.132873130.davem@davemloft.net>
References: <20081016163644.GA2933@localhost.localdomain>
	<20081016233517.GA21243@localhost.localdomain>
	<48F81A62.5080507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751355AbYJQFX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 01:23:26 -0400
In-Reply-To: <48F81A62.5080507@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 17 Oct 2008 06:53:54 +0200

> Please respin your patch to last tree, this misses my last patch about
> memory barrier...
> 
> Ah, maybe David did not committed it yet...

It's there in net-2.6
