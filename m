From: David Brownell <david-b@pacbell.net>
Subject: Re: WARNING: at net/core/dev.c:1344 __netif_schedule+0x26/0x76()
Date: Wed, 23 Jul 2008 15:21:41 -0700
Message-ID: <200807231521.41393.david-b@pacbell.net>
References: <200807231325.25672.david-b@pacbell.net> <20080723.140734.28877846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp117.sbc.mail.sp1.yahoo.com ([69.147.64.90]:24735 "HELO
	smtp117.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753762AbYGWWVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 18:21:43 -0400
In-Reply-To: <20080723.140734.28877846.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 July 2008, David Miller wrote:
> 
> > What change to device initialization is needed remove this warning?
> 
> Just ignore it, I'm going to remove the warning today.

OK -- that's easier than I had hoped!  :)

Thanks.

- dave
