From: Amir Vadai <amirv@mellanox.com>
Subject: Re: Patchset - Support for configurable RSS hash key
Date: Wed, 5 Feb 2014 14:24:43 +0200
Message-ID: <52F22D8B.4000408@mellanox.com>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8B7@CMEXMB1.ad.emulex.com> <20140202161016.GA17000@mtl-eit-vdi-22.mtl.labs.mlnx> <BF3270C86E8B1349A26C34E4EC1C44CB2C86E05F@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:33441 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750723AbaBEMYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 07:24:49 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C86E05F@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2014 14:20, Venkata Duvvuru wrote:
> 
> 
>> -----Original Message-----
>> From: Amir Vadai [mailto:amirv.mellanox@gmail.com] On Behalf Of Amir
>> Vadai
>> Sent: Sunday, February 02, 2014 9:40 PM
>> To: Venkata Duvvuru
>> Cc: netdev@vger.kernel.org; Ben Hutchings
>> Subject: Re: Patchset - Support for configurable RSS hash key
>>
>> On 17/01/14 13:02 +0000, Venkata Duvvuru wrote:
>>> NIC drivers that support RSS use either a hard-coded value or a random
>> value for the RSS hash key. Irrespective of the type of the key used, the user
>> would want to change the hash key if he/she is not satisfied with the
>> effectiveness of the default hash-key in spreading the incoming flows evenly
>> across the RSS queues.
>>>
>>> This patch set provides support for configuring the RSS hash-key via the
>> ethtool interface.
>>>
>>> The patch set consists of:
>>> a) ethtool user-land patches
>>> b) ethtool kernel patch
>>> c) be2net patch that implements the ethtool hooks
>>
>> Hi,
>>
>> I would be happy to add support in setting the hash function in addition to
>> the hash key.
>>
>> Mellanox NIC's have support in 2 hash functions: Toplitz and XOR.
>>
>> Let me if you can add it to your patchset or would like me to send a patch on
>> top of yours to add it.
> 
> I would prefer you to add the proposed changes on top my patchset. I'm working on the review comments currently and I will post the patchset once the patches are ready.

Ok,

I will send as soon as your patchset be applied.

Thanks,
Amir
