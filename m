From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2] net_sched: tbf: support of 64bit rates
Date: Fri, 08 Nov 2013 22:17:13 +0300
Message-ID: <527D38B9.8000709@cogentembedded.com>
References: <1383877414-9488-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jhs@mojatatu.com
To: Yang Yingliang <yangyingliang@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:33644 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756932Ab3KHSRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 13:17:23 -0500
Received: by mail-la0-f53.google.com with SMTP id eh20so2007069lab.26
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 10:17:22 -0800 (PST)
In-Reply-To: <1383877414-9488-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/08/2013 05:23 AM, Yang Yingliang wrote:

> With psched_ratecfg_precompute(), tbf can deal with 64bit rates.
> Add two new attributes so that tc can use them to break the 32bit
> limit.

> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

    It's too great a honor for me, I didn't suggest this patch. :-)
You can replace that with Reviewed-by: line.

WBR, Sergei
