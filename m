From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Sun, 28 Sep 2003 20:47:58 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030928234757.GI1039@conectiva.com.br>
References: <20030928225941.GW15338@fs.tum.de> <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de> <20030928233909.GG1039@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@fs.tum.de>, netdev@oss.sgi.com, davem@redhat.com,
        pekkas@netcore.fi, lksctp-developers@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20030928233909.GG1039@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Sun, Sep 28, 2003 at 08:39:10PM -0300, Arnaldo C. Melo escreveu:
> Simply removing the ifdefs in the headers will not help, leaving it in the
> kernel will bloat general purpose kernels, so can we live with this limitation

s/leaving it in the kernel/making it always statically linked in the kernel if
selected/g

Sorry...

- Arnaldo
