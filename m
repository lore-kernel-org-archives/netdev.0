From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [stable] Re: [05/11] SMP fix for 6pack driver
Date: Sun, 17 Jul 2005 17:09:39 -0400
Message-ID: <20050717210939.GA11884@linux-mips.org>
References: <20050713184130.GA9330@kroah.com> <20050713184331.GG9330@kroah.com> <20050713220123.GA3292@electric-eye.fr.zoreil.com> <20050713221311.GA30039@kroah.com> <20050715193556.GB18059@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Francois Romieu <romieu@fr.zoreil.com>,
	Greg KH <gregkh@suse.de>, torvalds@osdl.org, akpm@osdl.org,
	"Theodore Ts'o" <tytso@mit.edu>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	netdev@vger.kernel.org, Justin Forbes <jmforbes@linuxtx.org>,
	linux-kernel@vger.kernel.org,
	"Randy.Dunlap" <rdunlap@xenotime.net>,
	Chuck Wolber <chuckw@quantumlinux.com>, jgarzik@pobox.com,
	stable@kernel.org, alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261982AbVGSOCr@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050715193556.GB18059@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 15, 2005 at 09:35:56PM +0200, Adrian Bunk wrote:

> I do agree with Francois regarding this issue:
> 
> AFAIR, there has been not one 2.6 kernel where this driver was available 
> for SMP kernels.

Eh...  That after all is the raison d'etre for this patch :)

> It's therefore untested which problems might arise with 
> this driver on SMP systems. I'm not arguing against including this 
> driver in 2.6.13, but 2.6.12.3 isn't the right place.

Nonsense.  Most development activity for this stuff happens not on the
internet and you won't be able to follow it unless you're a licensed ham.
I've been circulating things patch since a while and nobody has been unhappy.

> What surprises me most is that you accepted this patch is neither in 
> 2.6.13-rc3 nor in 2.6.13-rc3-mm1. There seems to be either an
> (IMHO unfortunate) change in your policy of what patches to accept,
> or there's a serious problem in your patch review process.

I've sent it to jgarzik so it's somewhere on it's long way there.

  Ralf
