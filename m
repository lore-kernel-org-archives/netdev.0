From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] gso: Handle Trans-Ether-Bridging protocol in skb_network_protocol()
Date: Wed, 8 May 2013 19:32:40 -0700
Message-ID: <CALnjE+rkpy2vC84L2koq93=ZqHe3fN_1A-09yh=ugFMXBnzM3A@mail.gmail.com>
References: <1367995267-23443-1-git-send-email-pshelar@nicira.com>
	<20130508.131547.1016073329398924443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, amwang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:53178 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750774Ab3EICcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 22:32:42 -0400
Received: by mail-qc0-f181.google.com with SMTP id s10so1414177qcv.26
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 19:32:40 -0700 (PDT)
In-Reply-To: <20130508.131547.1016073329398924443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 8, 2013 at 1:15 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Tue,  7 May 2013 23:41:07 -0700
>
>> Rather than having logic to calculate inner protocol in every
>> tunnel gso handler move it to gso code. This simplifies code.
>>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Cong Wang <amwang@redhat.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> Applied.

Hi David,
Can you queue this patch for -stable ?

Thanks,
Pravin.
