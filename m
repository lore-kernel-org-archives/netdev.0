From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH net-next v2 00/12] net: ethernet: aquantia: improvements
 and fixes
Date: Sat, 18 Feb 2017 19:42:36 +0300
Message-ID: <77321dc8-89b8-3fc1-80db-bf585fbaf4c7@aquantia.com>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
 <6a2027ff-6725-4e8e-99fb-34c58542c393@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0060.outbound.protection.outlook.com ([104.47.42.60]:55104
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752358AbdBRQmx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 18 Feb 2017 11:42:53 -0500
In-Reply-To: <6a2027ff-6725-4e8e-99fb-34c58542c393@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02/18/2017 02:56 PM, Lino Sanfilippo wrote:
> Hi,
>
> On 17.02.2017 22:07, Pavel Belous wrote:
>> From: Pavel Belous <pavel.belous@aquantia.com>
>>
>> The following patchset contains improvements and fixes for aQuantia
>> AQtion ethernet driver from net-next tree.
>>
>> Most fixes are based on the comments from Lino Sanfilippo.
>>
>> Sanity testing was performed on real HW. No regression found.
>>
>> v1->v2 :Removed buffers copying.
>> 	Fixed dma error handling.
>>
>>
>> Please review.
>
> You could have added all "reviewed-by" tags that you have received so
> far for patches in the former version of this series. I think otherwise this
> information will get lost.
>
> Regards,
> Lino
>

I was thinking to add this tag, but i was unsure.

Thank you, I will add "Reviewed-by" tags for reviewed patches from v1 
(not changed) in patches v3.

Regards,
Pavel
