From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v2 net] net: filter: x86: fix JIT address randomization
Date: Thu, 15 May 2014 21:16:42 -0700
Message-ID: <5375912A.6090302@zytor.com>
References: <1400018755-3049-1-git-send-email-ast@plumgrid.com> <20140513.183145.1568789082256942703.davem@davemloft.net> <20140514080557.GB9848@osiris> <20140514.161038.604524051618558919.davem@redhat.com> <5373D4BF.1040002@zytor.com> <20140515065341.GB10217@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@redhat.com>, ast@plumgrid.com,
	edumazet@google.com, dborkman@redhat.com, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, "H. Peter Anvin" <hpa@linux.intel.com>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:48972 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbaEPERI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 00:17:08 -0400
In-Reply-To: <20140515065341.GB10217@osiris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/14/2014 11:53 PM, Heiko Carstens wrote:
> On Wed, May 14, 2014 at 01:40:31PM -0700, H. Peter Anvin wrote:
>> On 05/14/2014 01:10 PM, David Miller wrote:
>>> From: Heiko Carstens <heiko.carstens@de.ibm.com>
>>> Date: Wed, 14 May 2014 10:05:57 +0200
>>>
>>>> Dave, can you route this via -net?
>>>
>>
>> Pardon for being a bit confused, but it would seem x86 or net would be
>> the logical routes for this -- I don't mind at all it being routed
>> through net, but that would seem to be between myself (and the other x86
>> maintainers) and Dave...
> 
> [resending - and this time really added hpa's Intel email address]
> 
> Hi Peter,
> 
> you missed the s390 version of Alexei's patch which I sent as reply to this
> thread. As usual I got a delivery failure for your zytor.com email address
> (added your Intel address this time).
> 
> So the question was if Dave could add the s390 version of the patch to -net.
> 

OK, weird.  It seems IBM's mail server doesn't like me.  I wonder if it
is because of my using StartSSL for my TLS certificate.

	-hpa
