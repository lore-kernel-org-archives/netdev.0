From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] IP_RECVERRC
Date: Sat, 11 Aug 2007 15:27:20 -0400
Message-ID: <1186860440.5158.15.camel@localhost>
References: <1186752912.5188.12.camel@localhost>
	 <20070810140214.GA10331@one.firstfloor.org>
	 <1186756212.5163.4.camel@localhost>
	 <20070810162643.GA11892@one.firstfloor.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:42049 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbXHKT1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 15:27:25 -0400
Received: by wx-out-0506.google.com with SMTP id h31so842927wxd
        for <netdev@vger.kernel.org>; Sat, 11 Aug 2007 12:27:24 -0700 (PDT)
In-Reply-To: <20070810162643.GA11892@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 2007-10-08 at 18:26 +0200, Andi Kleen wrote:
> Are we talking about TCP or UDP/RAW?

Both. initially datagram.

I think you gave me something to think about - let me go back to the
drawing table. I like the per socket timer idea; however, if i can solve
from the app (or write my own app which is fine) then i will rather go
that path.
Thanks for taking the time Andi.

cheers,
jamal

