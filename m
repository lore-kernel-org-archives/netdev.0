From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of "foo*"
 and "foo * bar"
Date: Fri, 28 Mar 2014 17:30:27 +0400
Message-ID: <53357973.3010900@cogentembedded.com>
References: <1395979624-8544-1-git-send-email-wangyufen@huawei.com> <1395979624-8544-4-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Wangyufen <wangyufen@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:43108 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbaC1NaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 09:30:25 -0400
Received: by mail-lb0-f179.google.com with SMTP id p9so3747886lbv.10
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 06:30:23 -0700 (PDT)
In-Reply-To: <1395979624-8544-4-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 28-03-2014 8:07, Wangyufen wrote:

> From: Wang Yufen <wangyufen@huawei.com>

> ERROR: "(foo*)" should be "(foo *)"
> ERROR: "foo * bar" should be "foo *bar"
>
> Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

    I didn't really suggest to you to make this patch, I just commented on it.
You can instead add:

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
> ---
>   net/ipv6/ip6_fib.c | 30 +++++++++++++++---------------
>   1 file changed, 15 insertions(+), 15 deletions(-)

WBR, Sergei
