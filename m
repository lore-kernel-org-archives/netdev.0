From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [stable] PROBLEM: SIS900 Driver change in Linux Kernel 2.6.21
	causes kernel panic.
Date: Wed, 16 May 2007 18:42:52 -0700
Message-ID: <20070517014252.GD3429@sequoia.sous-sol.org>
References: <577536.90963.qm@web84207.mail.re3.yahoo.com> <20070516221704.GC16810@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: - <kd6lvw@yahoo.com>, Neil Horman <nhorman@tuxdriver.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Daniele Venzano <venza@brownhat.org>,
	Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:39474 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755753AbXEQBpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 21:45:46 -0400
Content-Disposition: inline
In-Reply-To: <20070516221704.GC16810@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Dave Jones (davej@redhat.com) wrote:
> You need this..
> 
> http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Ftorvalds%2Flinux-2.6.git;a=commitdiff_plain;h=dc5a144991ba803bc8afded105c9db1dea0e57ab
> 
> Which is queued for -stable afaik, but no sign of 2.6.21.2 yet. Greg/Chris?

Yes, it is queued, pushing out the current queue now.  Once Greg and I
compare notes we'll be ready to run the next review cycle.

thanks,
-chris
