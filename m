From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH][net-next] net: avoid to call skb_queue_len again
Date: Mon, 08 Dec 2014 19:51:29 +0300
Message-ID: <5485D711.4070704@cogentembedded.com>
References: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>	 <5481BBF2.40806@cogentembedded.com>	 <1417789870.15618.1.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAJFZqHzeESfMBqb1gQr4DsE-v_fSfUX+AyWbt_VriJJ8Dj2FnA@mail.gmail.com>	 <54858B56.1020607@cogentembedded.com> <1418051436.15618.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li RongQing <roy.qing.li@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:61869 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbaLHQvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 11:51:33 -0500
Received: by mail-lb0-f176.google.com with SMTP id p9so3968979lbv.7
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 08:51:32 -0800 (PST)
In-Reply-To: <1418051436.15618.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/08/2014 06:10 PM, Eric Dumazet wrote:

>>      I expect you to also refine the description, so that it's meaningful,
>> unlike now.

> It seems obvious to me Li is not a native English speaker.

    Me neither. :-)
    However, the good command of English language was a requirement when I was 
first hired to do the Linux development.

> I understood
> the patch very well, and the changelog seemed fine to me.

    Oh, if you say so...

> What about you provide this description instead, since you seem to care
> very much ?

    I mostly care for others; I don't suppose much people except you are able 
to understand the current variant. And I now have neither enough time nor 
enough understanding to write a proper description for this patch. I can only 
suggest that you refine the description for others if you can understand it so 
well.

> Thanks !

    Not at all.

WBR, Sergei
