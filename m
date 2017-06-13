From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next] fjes: remove duplicate set of flag IFF_BROADCAST
Date: Tue, 13 Jun 2017 18:55:08 +0300
Message-ID: <054ebc9e-5c41-d59b-84be-a84feb3baf92@cogentembedded.com>
References: <1497358189-3342-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        davem@davemloft.net, izumi.taku@jp.fujitsu.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35040 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753038AbdFMPzM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 11:55:12 -0400
Received: by mail-lf0-f53.google.com with SMTP id p189so75398405lfe.2
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 08:55:11 -0700 (PDT)
In-Reply-To: <1497358189-3342-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 06/13/2017 03:49 PM, Zhang Shengju wrote:

> Remove unnecessary set of flag IFF_BROADCAST, since ether_setup

    s/set/setting/. Perhaps can be fixed while applying...

> already does this.
>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
[...]

MBR, Sergei
