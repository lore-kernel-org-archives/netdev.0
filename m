From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: [patch (testing)] Re: 2.6.20->2.6.21 - networking dies after random time
Date: Fri, 10 Aug 2007 12:43:43 +0200
Message-ID: <4bacf17f0708100343r950cf90kbf826e2afc826df5@mail.gmail.com>
References: <20070806070300.GA4509@elte.hu>
	 <20070807082321.GB2120@ff.dom.local>
	 <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com>
	 <20070807095246.GB3223@ff.dom.local>
	 <20070807121339.GA3946@ff.dom.local>
	 <4bacf17f0708080409t116b5c84ye60dff7da51d0fdf@mail.gmail.com>
	 <20070808114243.GC2426@ff.dom.local>
	 <20070809091919.GB2423@ff.dom.local>
	 <4bacf17f0708092333n17e0ba19jf2c769531610868d@mail.gmail.com>
	 <20070810071038.GA1764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070810071038.GA1764@ff.dom.local>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/8/10, Jarek Poplawski <jarkao2@o2.pl>:
> (..)
> I think, there is this one possible for your testing yet?:
> Subject: [patch] genirq: temporary fix for level-triggered IRQ resend
> Date: Wed, 8 Aug 2007 13:00:37 +0200
I think I already tested this patch, but this thread is sooo big and I
can't find my response...

> If it's not a great problem it would be interesting to try this with
> different CONFIG_HZ too e.g. you could start with 100 (I guess, you
> tested very similar thing in 2.6.23-rc2 with 1000(?) already).
My all tests were done on 2.6.22.1

Marcin
