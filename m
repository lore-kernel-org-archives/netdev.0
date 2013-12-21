From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Sat, 21 Dec 2013 16:09:24 -0500
Message-ID: <52B60384.6000002@mojatatu.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com> <CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:62944 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050Ab3LUVJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 16:09:28 -0500
Received: by mail-ie0-f176.google.com with SMTP id at1so4598782iec.21
        for <netdev@vger.kernel.org>; Sat, 21 Dec 2013 13:09:27 -0800 (PST)
In-Reply-To: <CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/13 18:49, Cong Wang wrote:

> Jamal, any comments on this patch itself?
>

I think the idea is good. Sorry havent paid close
attention - starting to look at what is already
in net-next. I could pass you a test or two to run
for this change...

cheers,
jamal
