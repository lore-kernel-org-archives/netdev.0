From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: Re: stmmac driver...
Date: Wed, 14 Dec 2016 12:05:50 +0800
Message-ID: <8d624fd3-8440-5b8a-ee8d-558a671eec60@synopsys.com>
References: <20161207.130654.1484281922991494182.davem@davemloft.net>
 <35edb551-518e-f59f-7a9e-db108d8f42a7@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        David Miller <davem@davemloft.net>, <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:35516 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932109AbcLNEIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 23:08:13 -0500
In-Reply-To: <35edb551-518e-f59f-7a9e-db108d8f42a7@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

On 2016/12/12 22:17, Giuseppe CAVALLARO wrote:
> Hi David
>
> On 12/7/2016 7:06 PM, David Miller wrote:
>>
>> Giuseppe and Alexandre,
>>
>> There are a lot of patches and discussions happening around the stammc
>> driver lately and both of you are listed as the maintainers.
>>
>> I really need prompt and conclusive reviews of these patch submissions
>> from you, and participation in all discussions about the driver.
>
> yes we are trying to do the best.
>
>> Otherwise I have only three things I can do: 1) let the patches rot in
>> patchwork for days 2) trust that the patches are sane and fit your
>> desires and goals and just apply them or 3) reject them since they
>> aren't being reviewed properly.
>
> at this stage, I think the best is: (3).
I think the patches David mentioned also included XLGMAC. He sent this email
before I explained QoS and XLGMAC were different IPs. Do you mind we do XLGMAC
development under drivers/net/ethernet/synopsys/ ? I think we don't have
conflict since we will keep QoS development in stmmac.
>
>>
>> Thanks in advance.
>>
> you are welcome
>
>
> Peppe
