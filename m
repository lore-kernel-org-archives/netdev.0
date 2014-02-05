From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [GIT PULL] tree-wide: clean up no longer required #include
 <linux/init.h>
Date: Wed, 5 Feb 2014 07:06:33 +0100
Message-ID: <20140205060633.GE30094@gmail.com>
References: <1391547118-21967-1-git-send-email-paul.gortmaker@windriver.com>
 <CAP=VYLp+zus5591g-1YQBCJifbk+UY59yJ7rV06ZN3QhhdnK7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	x86@kernel.org, linux-ia64@vger.kernel.org,
	linux-mips@linux-mips.org, linux-m68k@vger.kernel.org,
	akpm@linux-foundation.org, sfr@canb.auug.org.au,
	gregkh@linuxfoundation.org, rusty@rustcorp.com.au,
	linux-arch@vger.kernel.org, kvm@vger.kernel.org,
	linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:40860 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbaBEGGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 01:06:38 -0500
Content-Disposition: inline
In-Reply-To: <CAP=VYLp+zus5591g-1YQBCJifbk+UY59yJ7rV06ZN3QhhdnK7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Paul Gortmaker <paul.gortmaker@windriver.com> wrote:

> On Feb 4, 2014 3:52 PM, "Paul Gortmaker" <paul.gortmaker@windriver.com>
> wrote:
> >
> > We've had this in linux-next for 2+ weeks (thanks Stephen!) as a
> > linux-stable like queue of patches, and as can be seen here:
> >
> >   https://git.kernel.org/pub/scm/linux/kernel/git/paulg/init.git
> 
> Argh, above link is meant for cloning, not viewing.
> 
> This should be better...
> 
> https://git.kernel.org/cgit/linux/kernel/git/paulg/init.git/

So, if you meant Linus to pull it, you probably want to cite a real 
Git URI along the lines of:

   git://git.kernel.org/pub/scm/linux/kernel/git/paulg/init.git

( Otherwise your pull request might be ignored or worse, you might get
  an honest reply, due to the https transport being considered evil
  that no free man outside of corporate firewalls should ever consider
  and all that. )

Nice cleanups btw.

Thanks,

	Ingo
