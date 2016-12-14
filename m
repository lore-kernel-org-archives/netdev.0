From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac driver...
Date: Wed, 14 Dec 2016 08:33:13 +0100
Message-ID: <d8d00654-a07e-2992-a911-3b88f1d3d3ac@st.com>
References: <20161207.130654.1484281922991494182.davem@davemloft.net>
 <35edb551-518e-f59f-7a9e-db108d8f42a7@st.com>
 <8d624fd3-8440-5b8a-ee8d-558a671eec60@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jie Deng <Jie.Deng1@synopsys.com>,
        David Miller <davem@davemloft.net>, <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:45984 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753184AbcLNIvB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 03:51:01 -0500
In-Reply-To: <8d624fd3-8440-5b8a-ee8d-558a671eec60@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jie

On 12/14/2016 5:05 AM, Jie Deng wrote:
> Hi Peppe,
>
> On 2016/12/12 22:17, Giuseppe CAVALLARO wrote:
>> Hi David
>>
>> On 12/7/2016 7:06 PM, David Miller wrote:
>>>
>>> Giuseppe and Alexandre,
>>>
>>> There are a lot of patches and discussions happening around the stammc
>>> driver lately and both of you are listed as the maintainers.
>>>
>>> I really need prompt and conclusive reviews of these patch submissions
>>> from you, and participation in all discussions about the driver.
>>
>> yes we are trying to do the best.
>>
>>> Otherwise I have only three things I can do: 1) let the patches rot in
>>> patchwork for days 2) trust that the patches are sane and fit your
>>> desires and goals and just apply them or 3) reject them since they
>>> aren't being reviewed properly.
>>
>> at this stage, I think the best is: (3).
> I think the patches David mentioned also included XLGMAC. He sent this email
> before I explained QoS and XLGMAC were different IPs. Do you mind we do XLGMAC
> development under drivers/net/ethernet/synopsys/ ? I think we don't have
> conflict since we will keep QoS development in stmmac.

Great. Many thanks for the clarification :-)

Regards
Peppe

>>
>>>
>>> Thanks in advance.
>>>
>> you are welcome
>>
>>
>> Peppe
>
>
