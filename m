From: David Miller <davem@davemloft.net>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Tue, 13 Oct 2009 00:27:57 -0700 (PDT)
Message-ID: <20091013.002757.226624584.davem@davemloft.net>
References: <20091013050705.GA2194@1wt.eu>
	<20091013.001106.226276168.davem@davemloft.net>
	<20091013071955.GA3587@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933683AbZJMH2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:28:00 -0400
In-Reply-To: <20091013071955.GA3587@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Tue, 13 Oct 2009 09:19:55 +0200

> On Tue, Oct 13, 2009 at 12:11:06AM -0700, David Miller wrote:
>> Your logic looks sound and I can't come to any other conclusion
>> after going over this code, even going back to 2.4.x
>> 
>> Feel free to make a formal patch submission, thanks Willy.
> 
> Ok, here it comes (I used my explanation as the commit message).

Applied and queued up for -stable, thanks!
