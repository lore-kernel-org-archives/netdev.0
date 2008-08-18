From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 09:08:12 +0300
Message-ID: <200808180908.12552.denys@visp.net.lb>
References: <20080818042731.GA32637@gondor.apana.org.au> <20080818043645.GA32755@gondor.apana.org.au> <20080817.221314.193687456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:55645 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbYHRGJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 02:09:22 -0400
In-Reply-To: <20080817.221314.193687456.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 18 August 2008, David Miller wrote:
> All of this is now pushed to net-2.6 on kernel.org
So i can build & test net-2.6 from git? :-)
