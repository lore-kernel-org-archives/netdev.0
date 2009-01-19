From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Mon, 19 Jan 2009 14:34:22 -0800
Message-ID: <9929d2390901191434k3d5fa598kad5a797ca4928c70@mail.gmail.com>
References: <20090113092625.GA28015@gondor.apana.org.au>
	 <20090113092828.GA28052@gondor.apana.org.au>
	 <20090118.214729.257523668.davem@davemloft.net>
	 <20090119111656.GB2575@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f21.google.com ([209.85.217.21]:39085 "EHLO
	mail-gx0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbZASWeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 17:34:24 -0500
Received: by gxk14 with SMTP id 14so2743995gxk.13
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 14:34:23 -0800 (PST)
In-Reply-To: <20090119111656.GB2575@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2009 at 3:16 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Sun, Jan 18, 2009 at 09:47:29PM -0800, David Miller wrote:
>> From: Herbert Xu <herbert@gondor.apana.org.au>
>> Date: Tue, 13 Jan 2009 20:28:28 +1100
>>
>> > igb: Replace LRO with GRO
>>  ...
>> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>>
>> Have the crashes reported by Intel been sorted out yet?
>> If so, I'll queue this up for 2.6.30
>>
>> Otherwise please resubmit once the problem is resolved.
>
> I believe it should be cured.  But it wouldn't hurt to wait for
> them to reconfirm.
>
> Thanks,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
>

Last word I have from test is that igb loads fine now, and no kernel
panics have been reported.
Go ahead and queue it up for 2.6.30.

-- 
Cheers,
Jeff
