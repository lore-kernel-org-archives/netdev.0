From: "David S. Miller" <davem@redhat.com>
Subject: Re: Patch: IPv6/AMD64: bug in net/ipv6/ndisc.c
Date: Thu, 29 Jan 2004 16:56:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040129165645.4dde4ffc.davem@redhat.com>
References: <20040129221538.J24747@fi.muni.cz>
	<20040130.083743.20740540.yoshfuji@linux-ipv6.org>
	<20040129153953.3dd2cd23.davem@redhat.com>
	<20040130014031.31ec050f.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kas@informatics.muni.cz,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040130014031.31ec050f.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Jan 2004 01:40:31 +0100
Andi Kleen <ak@suse.de> wrote:

> Fine by me. I've been ignoring it forever. But don't you see it on sparc64 too?

Nope, for some reason gcc-3.2.3 on my systems is missing it.
Otherwise I would have killed this earlier :)
