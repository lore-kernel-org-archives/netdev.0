From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: Re: [net, 6/6] net: korina: version bump
Date: Tue, 17 Jan 2017 21:19:39 +0200
Message-ID: <CACiydbLu+sKihjKsGVV5kiruSAEwcpJFsUOyASxnBd6=5+xddQ@mail.gmail.com>
References: <1484674393-22515-1-git-send-email-roman@advem.lv> <e607e3a1-8227-7768-2234-6a3340f4a368@nbd.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@nbd.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:34696 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdAQTTl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:19:41 -0500
Received: by mail-vk0-f67.google.com with SMTP id r136so11876483vke.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 11:19:40 -0800 (PST)
In-Reply-To: <e607e3a1-8227-7768-2234-6a3340f4a368@nbd.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 January 2017 at 20:55, Felix Fietkau <nbd@nbd.name> wrote:
> On 2017-01-17 18:33, Roman Yeryomin wrote:
>> Signed-off-by: Roman Yeryomin <roman@advem.lv>
>> ---
>>  drivers/net/ethernet/korina.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
>> index 83c994f..c8fed01 100644
>> --- a/drivers/net/ethernet/korina.c
>> +++ b/drivers/net/ethernet/korina.c
>> @@ -66,8 +66,8 @@
>>  #include <asm/mach-rc32434/dma_v.h>
>>
>>  #define DRV_NAME     "korina"
>> -#define DRV_VERSION  "0.10"
>> -#define DRV_RELDATE  "04Mar2008"
>> +#define DRV_VERSION  "0.20"
>> +#define DRV_RELDATE  "15Jan2017"
> I think it would make more sense to remove this version instead of
> bumping it. Individual driver versions are rather pointless, the kernel
> version is more meaningful anyway.

OK, makes sense

Regards,
Roman
