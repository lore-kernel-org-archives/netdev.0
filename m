From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [IPSEC]: Fix reversed ICMP6 policy check
Date: Thu, 13 Dec 2007 12:19:26 +0100
Message-ID: <20071213111926.GA3159@ff.dom.local>
References: <20071213024918.GA731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:52920 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbXLMLOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 06:14:23 -0500
Received: by nf-out-0910.google.com with SMTP id g13so520420nfb.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 03:14:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071213024918.GA731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-12-2007 03:49, Herbert Xu wrote:
> On Thu, Dec 13, 2007 at 09:58:56AM +0800, Herbert Xu wrote:
>> [IPSEC]: Fix reversed ICMP6 policy check
> 
> While that won't crash anymore, it's still logically wrong.
> 
> Here's a more complete fix.

...even more than this!

Since more than a year each time I read your patches I wonder what
kind of special attachments you use they are so "unreadble" (blurred)
in Mozilla Thunderbird (but, I was never so desperate to study all
these mail RFCs). And now - BINGO! So, they are simply treated as
signatures! Nice trick! But, I see, you forgot about something this
time, and now it's all clear! (Actually, I probably need one more
year to find, how to turn off this sh...)

Thanks,
Jarek P.
