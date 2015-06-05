From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Thu, 04 Jun 2015 22:27:13 -0700
Message-ID: <55713331.9040608@roeck-us.net>
References: <20150514055824.GB6058@gondor.apana.org.au> <20150515.130257.1322224469755323983.davem@redhat.com> <20150516131628.GA981@gondor.apana.org.au> <20150516.171019.1206903516753105739.davem@davemloft.net> <20150604162727.GA2670@roeck-us.net> <20150605035227.GA527@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	tgraf@suug.ch, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:46064 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbbFEF1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 01:27:17 -0400
In-Reply-To: <20150605035227.GA527@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2015 08:52 PM, Herbert Xu wrote:
> On Thu, Jun 04, 2015 at 09:27:27AM -0700, Guenter Roeck wrote:
>>
>> sorry for bothering you - I don't see this patch in any of your trees,
>> and it is marked as "changes requested" in patchwork. Did I look
>> at the wrong places, do you still plan to apply the patch as-is,
>> or do you expect some changes ?
>
> I just looked up the patchwork entry and it actually says "not
> applicable" which is correct:
>
> https://patchwork.ozlabs.org/patch/473041/
>
> Because the patch only applies to stable and is not needed in either
> net or net-next.
>

Ah, so I was looking at the wrong branch after all.

Thanks a lot for the clarification,

Guenter
