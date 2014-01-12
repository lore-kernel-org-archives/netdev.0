From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 5/7] net_sched: avoid casting void pointer
Date: Sun, 12 Jan 2014 07:55:15 -0500
Message-ID: <52D290B3.2080800@mojatatu.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com> <1389312845-10304-6-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:49106 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbaALMzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 07:55:17 -0500
Received: by mail-ie0-f178.google.com with SMTP id x13so316985ief.37
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 04:55:17 -0800 (PST)
In-Reply-To: <1389312845-10304-6-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/14 19:14, Cong Wang wrote:
> tp->root is a void* pointer, no need to cast it.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
