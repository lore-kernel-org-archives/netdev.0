From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 4/8] net_sched: cls: refactor out struct tcf_ext_map
Date: Wed, 18 Dec 2013 09:36:57 -0500
Message-ID: <52B1B309.6010105@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com> <1387167311-14763-5-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:40898 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379Ab3LROg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:36:59 -0500
Received: by mail-ie0-f172.google.com with SMTP id qd12so10362982ieb.17
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:36:59 -0800 (PST)
In-Reply-To: <1387167311-14763-5-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/13 23:15, Cong Wang wrote:
> These information can be saved in tcf_exts, and this will
> simplify the code.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Looks good, thanks.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
