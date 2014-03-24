From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next] ipv4: remove ip_rt_dump from route.c
Date: Mon, 24 Mar 2014 13:22:50 +0800
Message-ID: <CAJFZqHxT2MxtmKsRG=AQ-fX4XS18zvLizGcQL_dPLRgCn=bodA@mail.gmail.com>
References: <1395372790-11056-1-git-send-email-roy.qing.li@gmail.com>
	<20140321.153844.1012685520499183330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:59373 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaCXFWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 01:22:51 -0400
Received: by mail-qa0-f52.google.com with SMTP id m5so4823202qaj.39
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 22:22:50 -0700 (PDT)
In-Reply-To: <20140321.153844.1012685520499183330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 22, 2014 at 3:38 AM, David Miller <davem@davemloft.net> wrote:
> From: roy.qing.li@gmail.com
> Date: Fri, 21 Mar 2014 11:33:10 +0800
>
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> ip_rt_dump do nothing after IPv4 route caches removal, so we can remove it.
>>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>
> Applied, thanks.

Seems this patch was lost, I did not see it in net-next

-Roy
