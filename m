From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] tipc: make the code look more readability
Date: Wed, 25 Dec 2013 20:27:34 +0800
Message-ID: <52BACF36.8010908@gmail.com>
References: <1387937473-5804-1-git-send-email-wangweidong1@huawei.com> <1387937473-5804-3-git-send-email-wangweidong1@huawei.com> <52BAB7DA.6000706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	jeremy.kalman@windriver.com, jon.maloy@ericsson.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:45829 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab3LYM1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 07:27:03 -0500
Received: by mail-pa0-f42.google.com with SMTP id lj1so7435818pab.29
        for <netdev@vger.kernel.org>; Wed, 25 Dec 2013 04:27:02 -0800 (PST)
In-Reply-To: <52BAB7DA.6000706@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>

On 2013/12/25 18:47, Sergei Shtylyov wrote:
> Hello.
>
> On 25-12-2013 6:11, Wang Weidong wrote:
>
>> In commit 3b8401fe9d ("tipc: kill unnecessary goto's") didn't make
>> the code look most readability,
>
>     Only "readable". The same error in the subject.
>
Thanks. I will fix it in v3.

Regards,
Wang

>> so fix it. This patch is cosmetic
>> and does not change the operation of TIPC in any way.
>
>> Suggested-by: David Laight <David.Laight@ACULAB.COM>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>   net/tipc/socket.c | 7 ++-----
>>   1 file changed, 2 insertions(+), 5 deletions(-)
>
> WBR, Sergei
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
