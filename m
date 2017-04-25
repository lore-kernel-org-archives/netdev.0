From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sparc64: Improve 64-bit constant loading in
 eBPF JIT.
Date: Mon, 24 Apr 2017 23:28:02 -0400 (EDT)
Message-ID: <20170424.232802.2056583278183102508.davem@davemloft.net>
References: <20170424.225334.898469015162314835.davem@davemloft.net>
        <74973b5c-5380-b27b-3cf6-7b1444cade02@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        daniel@iogearbox.net
To: ast@fb.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <74973b5c-5380-b27b-3cf6-7b1444cade02@fb.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 24 Apr 2017 20:18:56 -0700

> all gcc-ism actually gives confidence that most likely
> it's all good and battle proven logic :)

Yes, this is old code written 15 years ago :)

I'll fix up the spaces.
