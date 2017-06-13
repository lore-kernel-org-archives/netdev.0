From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next] macvlan: propagate the mac address change status for
 lowerdev
Date: Tue, 13 Jun 2017 18:53:32 +0300
Message-ID: <ce72ad69-ae48-d10f-fee7-7ed004c8221d@cogentembedded.com>
References: <1497365111-34821-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        davem@davemloft.net, fgao@ikuai8.com, vyasevic@redhat.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34406 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbdFMPxi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 11:53:38 -0400
Received: by mail-lf0-f47.google.com with SMTP id v20so75460255lfa.1
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 08:53:37 -0700 (PDT)
In-Reply-To: <1497365111-34821-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 06/13/2017 05:45 PM, Zhang Shengju wrote:

> The macvlan dev should propagate the return value of mac address change for
> lower device in the passthru mode, instead of always return 0.

    Returning. Perhaps can be fixed while applying...

> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
[...]

MBR,Sergei
