From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Sun, 22 Dec 2013 11:26:59 -0500
Message-ID: <52B712D3.9050605@mojatatu.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com> <CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com> <52B60384.6000002@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:48133 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296Ab3LVQ1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 11:27:03 -0500
Received: by mail-ie0-f169.google.com with SMTP id e14so5179243iej.28
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 08:27:02 -0800 (PST)
In-Reply-To: <52B60384.6000002@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/13 16:09, Jamal Hadi Salim wrote:
> On 12/20/13 18:49, Cong Wang wrote:
>
>> Jamal, any comments on this patch itself?
>>
>
> I think the idea is good. Sorry havent paid close
> attention - starting to look at what is already
> in net-next. I could pass you a test or two to run
> for this change...
>


BTW: This indev feature was supposed to be "temporary";->
but has stuck around all these years. Not sure how widely it is
used. I will send you a testcase shortly. If it passes for you
please add my ACKed-by

cheers,
jamal
