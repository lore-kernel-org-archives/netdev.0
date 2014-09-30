From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] next: mips: bpf: Fix build failure
Date: Tue, 30 Sep 2014 16:59:51 -0400 (EDT)
Message-ID: <20140930.165951.1877491408006986300.davem@davemloft.net>
References: <1412095140-10953-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sfr@canb.auug.org.au
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412095140-10953-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 30 Sep 2014 09:39:00 -0700

> Fix:
> 
> arch/mips/net/bpf_jit.c: In function 'build_body':
> arch/mips/net/bpf_jit.c:762:6: error: unused variable 'tmp'
> cc1: all warnings being treated as errors
> make[2]: *** [arch/mips/net/bpf_jit.o] Error 1
> 
> Seen when building mips:allmodconfig in -next since next-20140924.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thank you.
