From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] rtnetlink: use the new rtnl_get_event()
 interface
Date: Tue, 30 May 2017 08:14:12 -0600
Message-ID: <99d1c4c1-45b3-b856-d668-cd0aab1bcc29@gmail.com>
References: <1496153222-13382-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33845 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdE3OON (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 10:14:13 -0400
Received: by mail-pf0-f193.google.com with SMTP id w69so18171584pfk.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 07:14:13 -0700 (PDT)
In-Reply-To: <1496153222-13382-1-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/30/17 8:07 AM, Vladislav Yasevich wrote:
> Small clean-up to rtmsg_ifinfo() to use the rtnl_get_event()
> interface instead of using 'internal' values directly.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  net/core/rtnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 

Acked-by: David Ahern <dsahern@gmail.com>
