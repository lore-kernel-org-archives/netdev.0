From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 1/1] net_sched: Introduce skbmod action
Date: Sun, 28 Aug 2016 08:18:08 -0400
Message-ID: <9d745599-c319-fac0-79ef-56b6abb0507e@mojatatu.com>
References: <1472386419-11943-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:35579 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755261AbcH1MSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 08:18:11 -0400
Received: by mail-it0-f54.google.com with SMTP id x131so64533613ite.0
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 05:18:10 -0700 (PDT)
In-Reply-To: <1472386419-11943-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-28 08:13 AM, Jamal Hadi Salim wrote:


> +#if 0
> +	if (lflags & SKBMOD_F_SWAPMAC)
> +		if ((lflags & SKBMOD_F_DMAC) || (lflags & SKBMOD_F_SMAC))
> +			return -EINVAL;
> +#endif


Sorry - left over from earlier. Will send v3 shortly.

cheers,
jamal
