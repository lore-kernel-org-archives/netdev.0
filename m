From: Andi Kleen <ak@suse.de>
Subject: Re: Patch: IPv6/AMD64: bug in net/ipv6/ndisc.c
Date: Fri, 30 Jan 2004 02:07:50 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040130020750.16e7d1b3.ak@suse.de>
References: <20040129221538.J24747@fi.muni.cz>
	<20040130.083743.20740540.yoshfuji@linux-ipv6.org>
	<20040129153953.3dd2cd23.davem@redhat.com>
	<20040130014031.31ec050f.ak@suse.de>
	<20040129165645.4dde4ffc.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kas@informatics.muni.cz,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040129165645.4dde4ffc.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, 29 Jan 2004 16:56:45 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Fri, 30 Jan 2004 01:40:31 +0100
> Andi Kleen <ak@suse.de> wrote:
> 
> > Fine by me. I've been ignoring it forever. But don't you see it on sparc64 too?
> 
> Nope, for some reason gcc-3.2.3 on my systems is missing it.

gcc 3.3 is printing it.

-Andi
