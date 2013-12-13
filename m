From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 2/6] net_sched: act: use standard struct list_head
Date: Fri, 13 Dec 2013 16:29:59 -0500
Message-ID: <52AB7C57.7010307@mojatatu.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>	<1386913673-8210-3-git-send-email-xiyou.wangcong@gmail.com>	<52AAF8CB.6060006@mojatatu.com> <CAM_iQpVYkvpEH91y-c9ng4fpB+sayiTXnkkszw1=RosazeFuBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:39986 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab3LMVaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 16:30:01 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so3552333ief.6
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 13:30:01 -0800 (PST)
In-Reply-To: <CAM_iQpVYkvpEH91y-c9ng4fpB+sayiTXnkkszw1=RosazeFuBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/13 13:48, Cong Wang wrote:

> My English is not good, I can only find "head" or "list" here,
> please suggest other better names?

One of the ones you replaced was simply "actions"; that would be
better.

cheers,
jamal
