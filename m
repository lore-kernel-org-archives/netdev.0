From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 1/7] net_sched: act: move idx_gen into struct
 tcf_hashinfo
Date: Sun, 12 Jan 2014 07:34:14 -0500
Message-ID: <52D28BC6.3090002@mojatatu.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com> <1389312845-10304-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:62711 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaALMeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 07:34:17 -0500
Received: by mail-ie0-f170.google.com with SMTP id tq11so6294992ieb.29
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 04:34:17 -0800 (PST)
In-Reply-To: <1389312845-10304-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/14 19:13, Cong Wang wrote:
> There is no need to store the index separatedly
> since tcf_hashinfo is allocated statically too.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

An improvement for sure. Thanks Cong!

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
