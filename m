From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next] stmmac: added device tree support for fixed_phy
 and phy_addr
Date: Fri, 14 Jun 2013 08:29:24 +0200
Message-ID: <51BAB844.4020102@st.com>
References: <019301ce67d4$ed1e32b0$c75a9810$%an@samsung.com> <51B9989F.5020603@st.com> <01b201ce6820$640897d0$2c19c770$%an@samsung.com> <150a01ce682e$a9e95ab0$fdbc1010$@org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Byungho An'" <bh74.an@samsung.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: "'Kukjin Kim'" <kgene@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:57720 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751320Ab3FNG3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 02:29:50 -0400
In-Reply-To: <150a01ce682e$a9e95ab0$fdbc1010$@org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/2013 2:08 PM, 'Kukjin Kim' wrote:
> Byungho An wrote:
>>
>>
>> On 6/13/2013 7:04 PM, Giuseppe CAVALLARO wrote:
>>> On 6/13/2013 3:25 AM, Byungho An wrote:
>>>>
>>>> This patch adds device tree support for fixed_phy and phy_addr it
>> means
>>>> fixed_phy and phy_addr can be set in device tree file. "fixed_phy" and
>>>> "phy_addr" can be added in the device tree blob.
>>>
>>> concerning this, we had added some work to pass from the platform
>>> the fixed bus name.
>>>
>>> http://git.stlinux.com/?p=stm/linux-
>>>
>> stm.git;a=blob;f=drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c;h=2
>> d540e1d2151e4412a5af5356d24d
>>> 5c6b66cf72e;hb=HEAD
>>>
> Looks good.
>
>>> I wanted to also do a clean-up and update the DT support because
>>> the binding documentation remains obsolete etc.
>>>
> Yeah, I see...
>
>>
>> I think your previous work for DT support can cover my patch.
>> Do you have a plan to update and clean-up for DT support?
>>
> Same here, would be nice if the patch could be seen in upcoming kernel.

for sure, I'll plan to send this work asasp

>
> If any help is required, let us know. Byungho will help you.

ok, thx

peppe

>
> Thanks,
> - Kukjin
>
>
>
