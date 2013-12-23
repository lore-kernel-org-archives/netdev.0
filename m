From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: act: Dont increment refcnt on replace
Date: Mon, 23 Dec 2013 08:07:12 -0500
Message-ID: <52B83580.2010601@mojatatu.com>
References: <52B6DC9B.9060309@mojatatu.com> <20131222.175015.561115381077901987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:51130 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756990Ab3LWNHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 08:07:16 -0500
Received: by mail-ig0-f169.google.com with SMTP id hk11so20954389igb.0
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 05:07:16 -0800 (PST)
In-Reply-To: <20131222.175015.561115381077901987.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/13 17:50, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Sun, 22 Dec 2013 07:35:39 -0500
>
>> This bug seems to have been around for some time, nothing to do with
>> recent changes; i am just doing tests i havent run in a while and
>> saw it. It is against net-next. If you think it is important enough,
>> I could also create one against linus tree..
>
> Jamal, I've tried to be patient with you over the years, but I really
> need you to start submitting your changes more cleanly.
>

Ok, let me know how this one went ;->
I think i know how to send this way if you find it fits your workflow.

cheers,
jamal
