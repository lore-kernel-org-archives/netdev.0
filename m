From: Just Marc <marc@corky.net>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 05:46:51 +0100
Message-ID: <445835BB.4050000@corky.net>
References: <E1Fb3qv-0005Vp-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:41914 "EHLO zebday.corky.net")
	by vger.kernel.org with ESMTP id S965056AbWECDrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 23:47:52 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1Fb3qv-0005Vp-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Just Marc <marc@corky.net> wrote:
>   
>> Looking at mailing list archives there has been much talk of this print 
>> in the past, given the fact that this check/print is surrounded by an 
>>     
>
> A good number of these turned out to be a bug in the Linux TCP stack.
> If this message wasn't there we would've never found it.
>   
Agreed, though this would be true for many other cases in the kernel 
should it be much more verbose in many other places.

We're now at 2.6.16.12 and it is still showing thousands of times a day 
on a busy web server, have all the bugs been discovered yet?

Marc
