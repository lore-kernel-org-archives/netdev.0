From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next] powerpc: use asm-generic/socket.h as much as possible
Date: Wed, 31 May 2017 10:37:20 +0200
Message-ID: <CAK8P3a3eoCTn4uDUptSreESvvQNsv9suzpuaZgq0n=-4NqFxeg@mail.gmail.com>
References: <20170531154337.04ebcb75@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        PowerPC <linuxppc-dev@lists.ozlabs.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34752 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdEaIhV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 04:37:21 -0400
Received: by mail-oi0-f44.google.com with SMTP id b204so7096055oii.1
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 01:37:21 -0700 (PDT)
In-Reply-To: <20170531154337.04ebcb75@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 7:43 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> asm-generic/socket.h already has an exception for the differences that
> powerpc needs, so just include it after defining the differences.
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Acked-by: Arnd Bergmann <arnd@arndb.de>
