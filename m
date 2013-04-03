From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH Resend] core: should call pskb_expand_head if skb header
 is cloned in skb_gso_segment in rx path
Date: Wed, 3 Apr 2013 09:44:27 +0800
Message-ID: <CAJFZqHw8USdorHwjJf7LKzPqetU2JbHR9uLcuurQ70O1hR2fLQ@mail.gmail.com>
References: <1364783861-3363-1-git-send-email-roy.qing.li@gmail.com>
	<1364905967.22165.4.camel@cr0>
	<CAJFZqHxn77yUpGkOUzywVR7wg2_L8tFaLNrFyaauuLWPJsQUHQ@mail.gmail.com>
	<1364951990.5113.192.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	jesse@nicira.com, pshelar@nicira.com,
	Herbert Xu <herbert@gondor.apana.org.au>, edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:54313 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760565Ab3DCBo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 21:44:28 -0400
Received: by mail-vc0-f171.google.com with SMTP id ha11so1096488vcb.16
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 18:44:27 -0700 (PDT)
In-Reply-To: <1364951990.5113.192.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK.

2013/4/3 Eric Dumazet <eric.dumazet@gmail.com>:
> On Wed, 2013-04-03 at 08:51 +0800, RongQing Li wrote:
>> No, I just read and analyze it, and think it is bogus.
>
> Please rewrite the changelog, because I read it several times and could
> not understand it.
>
>
>
>
