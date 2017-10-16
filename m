From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] tcp: Use pI6c in tcp tracepoint
Date: Mon, 16 Oct 2017 14:41:22 -0700
Message-ID: <CAM_iQpV5=uSzF3zBDPjrg9uhpLGk0tk07p0RLJgEvgOnSkSjDw@mail.gmail.com>
References: <1508189042-19591-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:53050 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752199AbdJPVln (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 17:41:43 -0400
Received: by mail-pg0-f50.google.com with SMTP id a192so6438153pge.9
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 14:41:43 -0700 (PDT)
In-Reply-To: <1508189042-19591-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 2:24 PM, David Ahern <dsahern@gmail.com> wrote:
> The compact form for IPv6 addresses is more user friendly than the full
> version. For example:
>    compact: 2001:db8:1::1
>       full: 2001:0db8:0001:0000:0000:0000:0000:0004i
>
> Update the tcp tracepoint to show the compact form.
>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

I was planning to send a same patch based on your
suggestion, you are faster than me. ;)
