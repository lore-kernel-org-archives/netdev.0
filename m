From: Auke Kok <sofar@foo-projects.org>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Tue, 02 May 2006 21:10:05 -0700
Message-ID: <44582D1D.909@foo-projects.org>
References: <E1Fb3qv-0005Vp-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Just Marc <marc@corky.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:25026 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S965081AbWECEKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 00:10:10 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1Fb3qv-0005Vp-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Just Marc <marc@corky.net> wrote:
>> Looking at mailing list archives there has been much talk of this print 
>> in the past, given the fact that this check/print is surrounded by an 
> 
> A good number of these turned out to be a bug in the Linux TCP stack.
> If this message wasn't there we would've never found it.

I am surprised that this never made it as a sysctl option that defaulted "on" 
in the first place really.

Auke
