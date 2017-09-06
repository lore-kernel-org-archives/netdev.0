From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC v3 0/4] Add cross-compilation support to eBPF samples
Date: Tue, 5 Sep 2017 20:24:21 -0700
Message-ID: <20170906032420.3bkvyz4p3wu2hyvy@ast-mbp>
References: <20170903182326.30547-1-joelaf@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        kernel-team@android.com, Juri Lelli <juri.lelli@arm.com>,
        Alison Chaiken <alison@she-devel.com>,
        Chenbo Feng <fengc@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: Joel Fernandes <joelaf@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34554 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752340AbdIFDYZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 23:24:25 -0400
Content-Disposition: inline
In-Reply-To: <20170903182326.30547-1-joelaf@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 03, 2017 at 11:23:21AM -0700, Joel Fernandes wrote:
> These patches fix issues seen when cross-compiling eBPF samples on arm64.
> Compared to [1], I dropped the controversial inline-asm patch pending further
> discussion on the right way to do it. However these patches are still a step in
> the right direction and I wanted them to get in before the more controversial
> bit.

All patches in this set look good to me.
When you repost without changes after net-next reopens pls keep my:
Acked-by: Alexei Starovoitov <ast@kernel.org>
