From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 2/2] tipc: make the code look more readability
Date: Wed, 25 Dec 2013 14:47:54 +0400
Message-ID: <52BAB7DA.6000706@cogentembedded.com>
References: <1387937473-5804-1-git-send-email-wangweidong1@huawei.com> <1387937473-5804-3-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>,
	jeremy.kalman@windriver.com, jon.maloy@ericsson.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:32874 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab3LYKrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 05:47:53 -0500
Received: by mail-lb0-f178.google.com with SMTP id c11so3186366lbj.23
        for <netdev@vger.kernel.org>; Wed, 25 Dec 2013 02:47:52 -0800 (PST)
In-Reply-To: <1387937473-5804-3-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-12-2013 6:11, Wang Weidong wrote:

> In commit 3b8401fe9d ("tipc: kill unnecessary goto's") didn't make
> the code look most readability,

    Only "readable". The same error in the subject.

> so fix it. This patch is cosmetic
> and does not change the operation of TIPC in any way.

> Suggested-by: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>   net/tipc/socket.c | 7 ++-----
>   1 file changed, 2 insertions(+), 5 deletions(-)

WBR, Sergei
