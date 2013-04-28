From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] x86: make DR*_RESERVED unsigned long
Date: Sun, 28 Apr 2013 19:39:32 +0200
Message-ID: <20130428173932.GA30773@redhat.com>
References: <20130424170702.GA1867@redhat.com> <5178282D.9030902@zytor.com> <20130425144818.GA25921@redhat.com> <20130426163802.GA30351@redhat.com> <517AAED5.7040400@zytor.com> <20130426171526.GA30875@redhat.com> <20130427144537.GA24256@redhat.com> <20130428005814.GB10354@somewhere> <20130428172731.GA26169@redhat.com> <517D5D3A.8070505@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <517D5D3A.8070505@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/28, H. Peter Anvin wrote:
>
> On 04/28/2013 10:27 AM, Oleg Nesterov wrote:
>
> Looks good.  However, given the timing, I would think this is 3.11
> material unless we have a manifest bug at this point.

Yes, yes, this is only cleanup.

> I have several bits like this that I'm going to queue up in a separate
> tip branch.

Great, thanks.

Oleg.
