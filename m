From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: [PATCH net-next v3] arm: eBPF JIT compiler
Date: Sun, 20 Aug 2017 01:32:55 +0530
Message-ID: <CAHgaXdKF7JFSWdDgmvne4qW=p9Tx+2=WQLwsa9i5cr0kvSb=WA@mail.gmail.com>
References: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com>
 <c2f4c796-0cb0-7eca-6cab-fed6b25020d5@fb.com> <CAHgaXdJnHxu4gJ8ZVFmrmaXyZL1oFkTbz2K___xKLQedTLmBQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>, Andrew Lunn <andrew@lunn.ch>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f177.google.com ([209.85.217.177]:33569 "EHLO
        mail-ua0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751613AbdHSUC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Aug 2017 16:02:57 -0400
In-Reply-To: <CAHgaXdJnHxu4gJ8ZVFmrmaXyZL1oFkTbz2K___xKLQedTLmBQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One more thing I forgot to mention.

I think this is the first implementation of eBPF JIT on any 32 bit
arch, correct me if I am wrong. I think we can use this as a POC to
implement eBPF on other 32 bit arch as well like x86, depends on its
need I guess.
