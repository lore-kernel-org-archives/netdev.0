From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Mon, 29 Sep 2003 22:17:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929221712.51e6c27b.davem@redhat.com>
References: <20030928225941.GW15338@fs.tum.de>
	<20030928231842.GE1039@conectiva.com.br>
	<20030928232403.GX15338@fs.tum.de>
	<20030928233909.GG1039@conectiva.com.br>
	<20030929001439.GY15338@fs.tum.de>
	<20030929003229.GM1039@conectiva.com.br>
	<1064826174.29569.13.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, bunk@fs.tum.de, netdev@oss.sgi.com,
        pekkas@netcore.fi, lksctp-developers@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1064826174.29569.13.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Sep 2003 10:02:55 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

> The underlying point being that your static kernel should not change if
> you change an option from 'n' to 'm'. It should only affect the kernel
> image if you change options to/from 'y'.

I totally disagree, what ipv6 is doing is perfectly fine.
