From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: socket: preferred __aligned(size) for control buffer
Date: Fri, 9 Dec 2016 14:14:23 +0300
Message-ID: <68c6da4f-eaaa-c572-c31d-d01618894ba6@cogentembedded.com>
References: <1481201513-20783-1-git-send-email-kushwaha.a@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akkushwaha9896@gmail.com
To: kushwaha.a@samsung.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35366 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752641AbcLILO0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 06:14:26 -0500
Received: by mail-wm0-f47.google.com with SMTP id a197so21858643wmd.0
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 03:14:26 -0800 (PST)
In-Reply-To: <1481201513-20783-1-git-send-email-kushwaha.a@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 12/8/2016 3:51 PM, kushwaha.a@samsung.com wrote:

> From: Amit Kushwaha <kushwaha.a@samsung.com>
>
> This patch cleanup checkpatch.pl warning
> WARNING: __aligned(size) is preferred over __attribute__((aligned(size)))
>
> Signed-off-by: Amit Kushwaha <kushwaha.a@samsung.com>
> ---
>  net/socket.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/socket.c b/net/socket.c
> index e631894..5835383 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1,3 +1,4 @@
> +

    Why?

>  /*
>   * NET		An implementation of the SOCKET network access protocol.
>   *
[...]

MBR, Sergei
