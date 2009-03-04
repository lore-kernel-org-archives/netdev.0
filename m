From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: WARNING: at net/core/dev.c:1505 skb_gso_segment+0x6e/0x156()
Date: Wed, 4 Mar 2009 10:19:34 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0903041018160.30758@potato.cts.ucla.edu>
References: <20090302041542.GA15961@gondor.apana.org.au>
 <Pine.LNX.4.64.0903021211120.28055@potato.cts.ucla.edu>
 <20090303022554.GA26217@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out-61.smtp.ucla.edu ([169.232.46.166]:50478 "EHLO
	out-61.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbZCDSUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 13:20:07 -0500
In-Reply-To: <20090303022554.GA26217@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Mar 2009, Herbert Xu wrote:
> On Mon, Mar 02, 2009 at 12:32:32PM -0800, Chris Stromsoe wrote:
>>
>> I am not seeing the warnings with 2.6.28.7 on the same hardware.  Did 
>> you want me to try with one of the 2.6..28-rcX kernels, or was that a 
>> typo for 2.6.29-rcX ?
>
> Sorry, I meant 2.6.29-rcX.
>
> If you're no longer seeing it with 2.6.28.7, then it's most likely the 
> result of a features computation bug that's already fixed.

I've been running with 2.6.28.7 on the same hardware for 2 days and 
haven't seen the warning once.  So it does look like something between 
those fixed it.



-Chris
