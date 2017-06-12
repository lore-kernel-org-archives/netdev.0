From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Sun, 11 Jun 2017 19:00:43 -0700
Message-ID: <CAGXu5jKHQNO8QtbfudLZ8vg1FmdLb3SiMikTvkEryggUQz=AcA@mail.gmail.com>
References: <1495754003-21099-1-git-send-email-illusionist.neo@gmail.com>
 <CAGXu5jKmLNMR+uhM9Ov2XPW6kCjip_SjScgEH0fTFp6fQtKFiA@mail.gmail.com> <CAHgaXdJ=-n8J8ot_5YQC=YMZrwTBvdNTp5Ta_J_J9vNGWQ4DCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36156 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752014AbdFLCAp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 22:00:45 -0400
Received: by mail-io0-f170.google.com with SMTP id y77so49768398ioe.3
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 19:00:45 -0700 (PDT)
In-Reply-To: <CAHgaXdJ=-n8J8ot_5YQC=YMZrwTBvdNTp5Ta_J_J9vNGWQ4DCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 6, 2017 at 12:47 PM, Shubham Bansal
<illusionist.neo@gmail.com> wrote:
> Hi Russell, Alexei, David, Daniel, kees,
>
> Any update on this patch moving forward?

Since this has gotten testing by various people and passes the
existing self-tests, I think this can probably go in via the ARM patch
tracker? Russell does that sound okay to you?

-Kees

-- 
Kees Cook
Pixel Security
