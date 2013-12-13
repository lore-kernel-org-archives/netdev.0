From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 16:40:27 -0500
Message-ID: <52AB7ECB.30702@mojatatu.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>	<1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>	<AE90C24D6B3A694183C094C60CF0A2F6026B7489@saturn3.aculab.com>	<CAM_iQpVgo+nxN3eTRg_F9u+-k4ML+D3ZqsrAEOeLZwtU6dOk3g@mail.gmail.com>	<52AB7BC6.9050503@mojatatu.com> <CAM_iQpWq64+Ae-ZESxGxGMLeFE2tRJeBGF+6E0-w5Qer2zk+3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:59628 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab3LMVk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 16:40:29 -0500
Received: by mail-ie0-f172.google.com with SMTP id qd12so3731145ieb.3
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 13:40:28 -0800 (PST)
In-Reply-To: <CAM_iQpWq64+Ae-ZESxGxGMLeFE2tRJeBGF+6E0-w5Qer2zk+3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/13 16:34, Cong Wang wrote:

> But no in-tree module implements it....

So? It is an API that is in there and expected by user space.

cheers,
jamal
