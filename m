From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 22 Jan 2007 10:19:18 +0300
Message-ID: <45B46576.1070104@tls.msk.ru>
References: <20070119110641.GA3135@ff.dom.local> <45B0C581.1020805@tls.msk.ru> <20070119140820.GA3424@ff.dom.local> <20070122071303.GB1634@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:20800 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891AbXAVHTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 02:19:25 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070122071303.GB1634@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Fri, Jan 19, 2007 at 03:08:20PM +0100, Jarek Poplawski wrote:
> ...
>> You are welcome! But you probably didn't read this with
>> attention: if it works, you should thank mainly to that
>> other guy...
>>
>> Btw. I can't remember I've seen such ferocious testing
>> ever!
> 
> After checking in the dictionary I found my btw. could
> be rather confusing:
> 
>> ferocious:
>> 1.savagely fierce, as a wild beast, person, action,
>>  or aspect; violently cruel: a ferocious beating.
>> 2.extreme or intense: a ferocious thirst. 
> 
> I've only meant #2 - and nothing like #1.
> If you were confused - sorry!

Heh.

Jarek, thank you for your apprecation of my efforts.

And no, I noticied this your statement in the first place
(in good sense - like, #2 above) -- I wanted to comment on
it first, but didn't.

I was only running tcpdump - yes, it was running almost the
whole day, with different options.  I did almost nothing.

You over-estimate my contribution, really ;)

The very good thing is that this bug is now found, and *that*
is what matters.

/mjt
