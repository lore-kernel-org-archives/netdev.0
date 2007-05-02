From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: netfront for review
Date: Tue, 01 May 2007 21:18:14 -0700
Message-ID: <46381106.8010605@goop.org>
References: <4637D672.5030706@goop.org> <1178077033.28659.173.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:44247 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbXEBESY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 00:18:24 -0400
In-Reply-To: <1178077033.28659.173.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> On Tue, 2007-05-01 at 17:08 -0700, Jeremy Fitzhardinge wrote:
>   
>> Add the Xen virtual network device driver.
>>     
>
> (Herbert: there's a question for you: grep for Herbert)
>
> OK, this is a remarkably non-trivial driver.  If the v0.1 of the driver
> had been in the kernel, I'm sure it would have been about 1/4 the size
> and far easier to review 8(
>
> Nonetheless, I have scoured the entire thing.  It's not actually too
> bad.
>   

Lovely, thanks.  I'm at the double disadvantage of not really knowing
how the network stack works or precisely how Xen does networking, but
the homework exercises ("comment this") will definitely help my education.

    J
