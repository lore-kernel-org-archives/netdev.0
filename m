From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] cxgb3: new code to deal with adapter
 parity errors
Date: Fri, 03 Sep 2010 10:04:38 -0700 (PDT)
Message-ID: <20100903.100438.123990943.davem@davemloft.net>
References: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53999
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755221Ab0ICREV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 13:04:21 -0400
In-Reply-To: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Thu, 2 Sep 2010 16:04:28 -0700

>   These patches implement code to detect and recover from adapter parity errors.
>
>   Two of the following four patches (2/4 and 3/4) were actually
>   implemented by Dimitris Michailidis just before he headed off for
>   vacation.  I've indicated that via a "Signed-off-by" by-line for
>   him as well as one for me which I _think_ is the right way to do
>   this.  The other two patches (1/4 and 4/4) were implemented by me
>   so I've only included a "Signed-off-by" for me on those.  If I've
>   done anything incorrectly please reject the patches and tell me
>   how to correct them.  Thanks!

All applied, thanks Casey.
