From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of foo
Date: Wed, 26 Mar 2014 17:45:26 +0400
Message-ID: <5332D9F6.6030405@cogentembedded.com>
References: <1395801446-8700-1-git-send-email-wangyufen@huawei.com> <1395801446-8700-4-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Wangyufen <wangyufen@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:38094 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159AbaCZNp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 09:45:28 -0400
Received: by mail-lb0-f178.google.com with SMTP id s7so1479213lbd.23
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 06:45:27 -0700 (PDT)
In-Reply-To: <1395801446-8700-4-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-03-2014 6:37, Wangyufen wrote:

> From: Wang Yufen <wangyufen@huawei.com>

    Unfortunately, your subject doesn't make much sense (I didn't notice it in 
the first review).

> ERROR: "(foo*)" should be "(foo *)"
> ERROR: "foo * bar" should be "foo *bar"

    Actually, it's the same space issues patch #1 fixes, so it's worth merging 
them...

> Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Wang Yufen <wangyufen@huawei.com>

WBR, Sergei
