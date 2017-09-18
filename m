From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: next build: 6 warnings 0 failures (next/next-20170918)
Date: Mon, 18 Sep 2017 16:22:19 +0200
Message-ID: <CAK8P3a3S3an1yxgHdBC7Rk46dTC1SSqhu54fz_OQnpx30n61nw@mail.gmail.com>
References: <59bf5fd0.0abf630a.bdef.c345@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Olof Johansson <olof@lixom.net>,
        Kernel Build Reports Mailman List
        <kernel-build-reports@lists.linaro.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Networking <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>
To: "Olof's autobuilder" <build@lixom.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59bf5fd0.0abf630a.bdef.c345@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 7:55 AM, Olof's autobuilder <build@lixom.net> wrote:
> Warnings:
>
>       6 net/netfilter/nf_nat_core.c:432:56: warning: division by zero [-Wdiv-by-zero]

Geert posted the fix for this last week:

https://patchwork.kernel.org/patch/9946253/

      Arnd
