From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 01/12] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 19 Jan 2015 08:11:00 -0800
Message-ID: <54BD2C94.8060202@gmail.com>
References: <20150113212941.13874.48692.stgit@nitbit.x32> <20150113213529.13874.16858.stgit@nitbit.x32> <20150119050937.GD5612@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, sfeldma@gmail.com, netdev@vger.kernel.org,
	gerlitz.or@gmail.com, jhs@mojatatu.com, andy@greyhouse.net,
	davem@davemloft.net
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:57632 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbbASQLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 11:11:22 -0500
Received: by mail-oi0-f53.google.com with SMTP id g201so27421718oib.12
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 08:11:22 -0800 (PST)
In-Reply-To: <20150119050937.GD5612@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2015 09:09 PM, Simon Horman wrote:
> [snip]
>
>> --- /dev/null
>> +++ b/net/core/flow_table.c
>> @@ -0,0 +1,942 @@
>> +/*
>> + * include/uapi/linux/if_flow.h - Flow table interface for Switch devices
>
> Hi John,
>
> its seems that the path in the above comment should be
> net/core/flow_table.c.
>
> [snip]
>

Thanks Simon, I've merged all three comments.

-- 
John Fastabend         Intel Corporation
