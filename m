From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 00/32] Swap over NFS - v19
Date: Fri, 3 Oct 2008 16:49:47 +1000
Message-ID: <200810031649.47800.nickpiggin@yahoo.com.au>
References: <20081002130504.927878499@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755251AbYJCGuK@vger.kernel.org>
In-Reply-To: <20081002130504.927878499@chello.nl>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 02 October 2008 23:05, Peter Zijlstra wrote:
> Patches are against: v2.6.27-rc5-mm1
>
> This release features more comments and (hopefully) better Changelogs.
> Also the netns stuff got sorted and ipv6 will now build and not oops
> on boot ;-)
>
> The first 4 patches are cleanups and can go in if the respective
> maintainers agree.
>
> The code is lightly tested but seems to work on my default config.
>
> Let's get this ball rolling...

I know it's not too helpful for me to say this, but I am spending
time looking at this stuff. I have commented on it in the past,
but I want to get a good handle on the code before I chime in again.
