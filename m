From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 8 Aug 2007 13:53:59 +0200
Message-ID: <20070808115359.GD2426@ff.dom.local>
References: <20070731132037.GC1046@ff.dom.local> <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com> <20070806070300.GA4509@elte.hu> <4bacf17f0708070046o14403089v8376a4544f72fec3@mail.gmail.com> <20070807082321.GB2120@ff.dom.local> <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com> <20070807095246.GB3223@ff.dom.local> <20070807121339.GA3946@ff.dom.local> <4bacf17f0708080409t116b5c84ye60dff7da51d0fdf@mail.gmail.com> <20070808114243.GC2426@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070808114243.GC2426@ff.dom.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 01:42:43PM +0200, Jarek Poplawski wrote:
...
> So, it looks like x86_64 io_apic's IPI code was unused too long...

To be fair it's x86_64 lapic's IPI code.

Jarek P.
