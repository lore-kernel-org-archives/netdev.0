From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Mon, 26 Jan 2009 12:46:54 -0500
Message-ID: <20090126174654.GA26064@csclub.uwaterloo.ca>
References: <E1LDRbc-0000Ro-1j@gondolin.me.apana.org.au> <1229641573.3726.563.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753776AbZAZSK6@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1229641573.3726.563.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 18, 2008 at 05:06:13PM -0600, Matt Mackall wrote:
> No one has printer ports any more so it hardly seems worth the trouble.

USB printers go through the same code.

> Most people won't actually think their printer is on fire. But most
> people WILL think there is serious cause for concern when they see this
> for the first time in dmesg. Many will search the net for explanations
> and come away confused and not entirely reassured. And at least one
> clueless guy will call the police because he still thinks he's under
> attack.

I dealt with an epson inkjet (USB based) a few years ago that would
reliably trigger that message when it was out of ink.  I thought it was
ammusing that they picked that signal to indicate out of ink.

Not sure if current models do it too.

> Now that certainly fits my definition of amusing and if my goal for
> Linux was to amuse myself at the expense of users, I'd be all for
> keeping it[1]. But perversely, I actually want users to enjoy their
> Linux experience.
> 
> [1] Hell, I'd probably even get them to use git.

-- 
Len Sorensen
