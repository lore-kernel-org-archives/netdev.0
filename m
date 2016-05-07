From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net: make sch_handle_ingress() drop monitor
 ready
Date: Sat, 7 May 2016 09:09:25 -0400
Message-ID: <572DE905.9030103@mojatatu.com>
References: <1462575350.13075.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35430 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbcEGNJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 09:09:32 -0400
Received: by mail-io0-f196.google.com with SMTP id u185so16712767iod.2
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 06:09:32 -0700 (PDT)
In-Reply-To: <1462575350.13075.60.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-06 06:55 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> TC_ACT_STOLEN is used when ingress traffic is mirred/redirected
> to say ifb.
>
> Packet is not dropped, but consumed.
>
> Only TC_ACT_SHOT is a clear indication something went wrong.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
