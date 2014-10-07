From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: pull request: wireless-next 2014-10-03
Date: Tue, 07 Oct 2014 09:45:28 -0500
Message-ID: <5433FC88.6040909@lwfinger.net>
References: <20141003180151.GE27414@tuxdriver.com>	<20141005.213511.339356320070784471.davem@davemloft.net>	<20141005.213853.488066614144870837.davem@davemloft.net> <20141007.004724.187788111776188480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:49860 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbaJGOpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 10:45:33 -0400
In-Reply-To: <20141007.004724.187788111776188480.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2014 11:47 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 05 Oct 2014 21:38:53 -0400 (EDT)
>
>> From: David Miller <davem@davemloft.net>
>> Date: Sun, 05 Oct 2014 21:35:11 -0400 (EDT)
>>
>>> From: "John W. Linville" <linville@tuxdriver.com>
>>> Date: Fri, 3 Oct 2014 14:01:52 -0400
>>>
>>>> Please pull tihs batch of updates intended for the 3.18 stream!
>>>
>>> Pulled, thanks for the stellar pull request text, as always.
>>
>> John, what's the deal with the following?  Will it be resolved by the
>> driver being removed from the staging tree?
>>
>> WARNING: drivers/staging/rtl8192ee/r8192ee: 'rtl_evm_dbm_jaguar' exported twice. Previous export was in drivers/net/wireless/rtlwifi/rtlwifi.ko
>
> John, ping?

David,

Yes, that message will go away once the removal of the staging driver, which was 
handled by GregKH, gets merged with the changes from John.

Larry
