From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 3/6] net_sched: act: hide struct tcf_common from
 API
Date: Mon, 20 Jan 2014 07:44:29 -0500
Message-ID: <52DD1A2D.5020205@mojatatu.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com> <1389987427-14085-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:62779 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbaATMod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 07:44:33 -0500
Received: by mail-ie0-f172.google.com with SMTP id e14so8218038iej.3
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 04:44:33 -0800 (PST)
In-Reply-To: <1389987427-14085-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/14 14:37, Cong Wang wrote:
> Now we can totally hide it from modules. tcf_hash_*() API's
> will operate on struct tc_action, modules don't need to care about
> the details.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Looks good.
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
