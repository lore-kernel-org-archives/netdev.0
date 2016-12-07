From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next] dummy: expend mtu range for dummy device
Date: Wed, 7 Dec 2016 13:14:25 +0300
Message-ID: <d143784d-94bc-a36b-1806-ddc9351a74c2@cogentembedded.com>
References: <1481103693-16394-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        jarod@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35540 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752425AbcLGKOZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 05:14:25 -0500
Received: by mail-wm0-f41.google.com with SMTP id a197so159868694wmd.0
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 02:14:25 -0800 (PST)
In-Reply-To: <1481103693-16394-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 12/7/2016 12:41 PM, Zhang Shengju wrote:

> After commit 61e84623ace3 ("net: centralize net_device min/max MTU checking"),
> the mtu range for dummy device becomes [68, 1500].
>
> This patch expends it to [0, 65535].

    "Extend" here and in the subject.

> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
[...]

MBR, Sergei
