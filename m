From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Wed, 31 Jul 2013 18:57:20 -0700
Message-ID: <1375322240.10515.115.camel@edumazet-glaptop>
References: <1375118644.10515.18.camel@edumazet-glaptop>
	 <20130730.191138.420648092010563209.davem@davemloft.net>
	 <20130731174854.GA27714@d2.synalogic.ca>
	 <20130731.120126.2193837817631047825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: benjamin.poirier@gmail.com, luis.henriques@canonical.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, jcliburn@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:64187 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050Ab3HAB5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 21:57:23 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so1433510pde.24
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 18:57:23 -0700 (PDT)
In-Reply-To: <20130731.120126.2193837817631047825.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 12:01 -0700, David Miller wrote:

> I know, I realized this when I sent the pull request to Linus.
> 
> Eric, your patch submission format is extremely error prone for me
> sometime.  When you submit patches in email thread, and do things like
> you did here, it causes problems sometimes.
> 
> Really just send it in the usual way, with the real Subject line
> matching the commit message header line you wish to use etc.
> 

Sorry for that, I'll do this next times !

Thanks !
