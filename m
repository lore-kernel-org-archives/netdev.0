From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH] netns: fix get_net_ns_by_fd(int pid) typo
Date: Fri, 18 Nov 2016 19:40:23 +0200
Message-ID: <CAKoUArni0cdhK4ePxkE0oqN-wQ=LDdoBOr9fNQpxuBDbgSQWGg@mail.gmail.com>
References: <1479462106-28529-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:34937 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752200AbcKRRkZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 12:40:25 -0500
Received: by mail-qt0-f171.google.com with SMTP id c47so161483707qtc.2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 09:40:24 -0800 (PST)
In-Reply-To: <1479462106-28529-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 November 2016 at 11:41, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> The argument to get_net_ns_by_fd() is a /proc/$PID/ns/net file
> descriptor not a pid.  Fix the typo.
>

Acked-by: Rami Rosen <roszenrami@gmail.com>
