From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [patch net] lib: Remove string from parman config selection
Date: Thu, 23 Feb 2017 11:08:20 +0100
Message-ID: <CAMuHMdWz=H6ynCuUv4P39C6jWUHBQtxRnjFok88Wi8NxgbKozQ@mail.gmail.com>
References: <1487843865-2253-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34301 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdBWKIW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 05:08:22 -0500
Received: by mail-it0-f67.google.com with SMTP id r141so1952908ita.1
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 02:08:21 -0800 (PST)
In-Reply-To: <1487843865-2253-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Thu, Feb 23, 2017 at 10:57 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> As reported by Geert, remove the string so the user does not see this
> config option. The option is explicitly selected only as a dependency of
> in-kernel users.

Thanks!

> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Fixes: 44091d29f207 ("lib: Introduce priority array area manager")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert
